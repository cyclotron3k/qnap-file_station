require 'json'
require 'net/http'
require 'openssl'
require 'base64'
require 'qnap/api_error'

module Qnap
	class FileStation
		DEBUG = false
		DISCARD_EXTRANEOUS = true
		PROTOCOL = 'https'

		API_METHODS = {
			cancel_compress: [:pid],
			cancel_extract: [:pid],
			cancel_transcode: [:pid],
			cancel_trash_recovery: [:pid],
			compress: [:compress_file, :compress_name, :encryipt, :level, :pwd, :total, :type],
			copy: [:dest_path, :dup, :mode, :source_file, :source_path, :source_total],
			createdir: [:dest_folder, :dest_path],
			delete: [:file_name, :file_total, :path],
			delete_share: [:download_link, :file_total, :filename],
			delete_share_all: [],
			delete_transcode: [:file_name, :file_total, :keep_trans, :mode, :path],
			download: [:compress, :isfolder, :source_file, :source_path, :source_total],
			extract: [:code_page, :dest_path, :extract_file, :mode, :overwrite, :path_mode, :pwd],
			get_compress_status: [:pid],
			get_domain_ip_list: [],
			get_extract_list: [:code_page, :dir, :extract_file, :limit, :path, :sort, :start],
			get_file_size: [:name, :name, :path, :total],
			get_list: [:dir, :filename, :flv_720, :hidden_file, :is_iso, :limit, :list_mode, :mp4_360, :mp4_720, :path, :sort, :start, :type],
			get_share_link: [:access_code, :access_enabled, :addressee, :content, :day, :download_type, :file_name, :file_total, :hostname, :hour, :include_access_code, :network_type, :path, :ssl, :subject, :valid_duration],
			get_share_list: [:dir, :limit, :sort, :start],
			get_thumb: [:name, :path, :size],
			get_tree: [:is_iso, :node],
			get_video_qstatus: [:pid],
			move: [:mode, :source_file, :source_path, :source_total],
			qrpac: [:op],
			rename: [:dest_name, :path, :source_name],
			search: [:dir, :keyword, :limit, :sort, :source_path, :start],
			share_file: [:access_code, :access_enabled, :addressee, :content, :day, :dowdownload_type, :expire_time, :file_name, :file_total, :hostname, :hour, :include_access_code, :link_url, :mail_content_date, :mail_content_pwd, :network_type, :path, :ssl, :subject, :valid_duration],
			stat: [:file_name, :file_total, :mtime, :path, :settime],
			trash_recovery: [:mode, :source_file, :source_path, :source_total],
			update_share_link: [:access_code, :access_enabled, :datetime, :dowdownload_type, :file_total, :hostname, :ssids, :ssl, :valid_duration],
			upload: [:dest_path, :overwrite, :progress, :type],
			video_list: [:source_path, :source_total],
			video_ml_queue: [:filename, :op, :path, :subop, :total],
			video_ml_status: [:filename, :path, :total],
		}

		def self.session(*args)
			ds = self.new *args
			begin
				yield ds
			ensure
				ds.logout
			end
		end

		API_METHODS.each do |method_name, fields|

			next if method_defined? method_name

			define_method method_name, Proc.new { |params={}|
				if (diff = fields - params.keys).count > 0
					puts "Missing keys: #{diff}" if DEBUG
				end

				if DISCARD_EXTRANEOUS and (diff = params.keys - fields).count > 0
					puts "Discarding extra keys: #{diff}"
					params.select! { |k, v| fields.include? k }
				end

				despatch_query @path, params.merge(func: method_name, sid: get_sid)
			}

		end

		alias get_network_players qrpac

		def login(params={})
			despatch_query(
				"/cgi-bin/filemanager/wfm2Login.cgi",
				params
			)
		end

		def logout(params={})
			return unless @sid
			despatch_query(
				"/cgi-bin/filemanager/wfm2Logout.cgi",
				params.merge(sid: @sid)
			)
			@sid = nil

			if @agent.started?
				@agent.finish
				puts "\e[1;32mClosing connection\e[0m" if DEBUG
			end
		end

		def get_sid
			@sid ||= login(user: @username, pwd: Base64.encode64(@password).strip)[:sid]
		end

		def initialize(host, username, password)
			@host     = host
			@username = username
			@password = password
			@sid      = nil
			@base_uri = URI "#{PROTOCOL}://#{@host}"
			@path     = "/cgi-bin/filemanager/utilRequest.cgi"
			@agent    = Net::HTTP.new @base_uri.host, @base_uri.port
			
			@agent.use_ssl = PROTOCOL == 'https',
			@agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
			@agent.keep_alive_timeout = 10
			@agent.set_debug_output $stdout if DEBUG
		end

		private

		def despatch_query(path, params)
			uri = @base_uri.clone
			uri.path = path
			uri.query = URI.encode_www_form(params) if params.keys.length > 0
			req = Net::HTTP::Get.new uri

			puts "\n\n\e[1;32mDespatching request to #{params[:func]}\e[0m" if DEBUG

			@session = @agent.start unless @agent.started?
			response = @session.request req

			puts "\e[1;32mResponse received\e[0m" if DEBUG

			unless (200..299).include? response.code.to_i
				raise "Error response from #{uri} -> #{response.read_body}"
			end

			case response['content-type']
				when /application\/json/
					data = JSON.parse response.read_body, symbolize_names: true
				when /application\/force-download/
					data = response.read_body.force_encoding('UTF-8')
				else
					raise "Don't know how to parse #{response['content-type']}"
			end

			if data.respond_to?(:key?) and data.key?(:status) and data[:status] != 1
				raise Qnap::ApiError.new data[:status], uri, response
			end

			data
		end
	end
end
