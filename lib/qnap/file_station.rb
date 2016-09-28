require 'json'
require 'net/http'
require 'openssl'
require 'base64'

module Qnap
	class FileStation
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
					puts "Missing keys: #{diff}"
				end

				if (diff = params.keys - fields).count > 0
					puts "Extra keys: #{diff}"
				end

				despatch_query @url, params.merge(func: method_name, sid: get_sid)
			}

		end

		def login(params={})
			despatch_query(
				"#{PROTOCOL}://#{@host}/cgi-bin/filemanager/wfm2Login.cgi",
				params
			)
		end

		def logout(params={})
			return unless @sid
			despatch_query(
				"#{PROTOCOL}://#{@host}/cgi-bin/filemanager/wfm2Logout.cgi",
				params.merge(sid: @sid)
			)
			@sid = nil
		end

		def get_sid
			@sid ||= login(user: @username, pwd: Base64.encode64(@password).strip)[:sid]
		end

		def initialize(host, username, password)
			@host     = host
			@username = username
			@password = password
			@sid      = nil
			@url      = "#{PROTOCOL}://#{@host}/cgi-bin/filemanager/utilRequest.cgi"
		end

		private

		def despatch_query(url, params)
			uri = URI url
			uri.query = URI.encode_www_form(params) if params.keys.length > 0
			req = Net::HTTP::Get.new uri

			response = Net::HTTP.start(
				uri.host,
				uri.port,
				use_ssl: PROTOCOL == 'https',
				verify_mode: OpenSSL::SSL::VERIFY_NONE
			) do |https|
				https.request req
			end

			unless (200..299).include? response.code.to_i
				raise RuntimeError.new "Error response from #{uri} -> #{response.read_body}"
			end

			unless response['content-type'] =~ /application\/json/
				raise "Don't know how to parse #{response['content-type']}"
			end
			
			data = JSON.parse response.read_body, symbolize_names: true
			
			if data.respond_to?(:key?) and data.key?(:status) and data[:status] != 1
				raise RuntimeError.new "Error response from #{uri} -> #{data}"
			end

			data
		end
	end
end

__END__
Error code, Token, Description
0 WFM2_FAIL UNKNOWN ERROR
1 WFM2_DONE SUCCESS
1 WFM2_SUCCESS SUCCESS
2 WFM2_FILE_EXIST FILE EXIST
3 WFM2_AUTH_FAIL Authentication Failure
4 WFM2_PERMISSION_DENY Permission Denied
5 WFM2_FILE_NO_EXIST FILE/FOLDER NOT EXIST
5 WFM2_SRC_FILE_NO_EXIST FILE/FOLDER NOT EXIST
6 WFM2_EXTRACTING FILE EXTRACTING
7 WFM2_OPEN_FILE_FAIL FILE IO ERROR
8 WFM2_DISABLE Web File Manager is not enabled.
9 WFM2_QUOTA_ERROR You have reached the disk quota limit.
10 WFM2_SRC_PERMISSION_DENY You do not have permission to perform this action.
11 WFM2_DES_PERMISSION_DENY You do not have permission to perform this action.
12 WFM2_ILLEGAL_NAME " + = / \ : | * ? < > ; [ ] % , ` '
13 WFM2_EXCEED_ISO_MAX The maximum number of allowed ISO shares is 256. Please unmount an ISO share
14 WFM2_EXCEED_SHARE_MAX The maximum number of shares is going to be exceeded.
15 WFM2_NEED_CHECK
16 WFM2_RECYCLE_BIN_NOT_ENABLE
17 WFM2_CHECK_PASSWORD_FAIL Enter password
18 WFM2_VIDEO_TCS_DISABLE
19 WFM2_DB_FAIL The system is currently busy. Please try again later.
19 WFM2_DB_QUERY_FAIL The system is currently busy. Please try again later.
20 WFM2_PARAMETER_ERROR There were input errors. Please try again later.
21 WFM2_DEMO_SITE Your files are now being transcoded.
22 WFM2_TRANSCODE_ONGOING Your files are now being transcoded.
23 WFM2_SRC_VOLUME_ERROR An error occurred in the source file. Please check and try again later.
24 WFM2_DES_VOLUME_ERROR A write error has occurred at the target destination. Please check and try again
25 WFM2_DES_FILE_NO_EXIST The target destination is unavailable. Please check and try again later.
26 WFM2_FILE_NAME_TOO_LONG 255 byte limit exceeded
27 WFM2_FOLDER_ENCRYPTION This folder has been encrypted. Please decrypt it and try again.
28 WFM2_PREPARE Processing now
29 WFM2_NO_SUPPORT_MEDIA This file format is not supported.
30 WFM2_DLNA_QDMS_DISABLE Please enable the DLNA Media Server
31 WFM2_RENDER_NOT_FOUND Cannot find any available DLNA devices.
32 WFM2_CLOUD_SERVER_ERROR The SmartLink service is currently busy. Please try again later.
33 WFM2_NAME_DUP That folder or file name already exists. Please use another name.
34 WFM2_EXCEED_SEARCH_MAX      1000
35 WFM2_MEMORY_ERROR
36 WFM2_COMPRESSING
37 WFM2_EXCEED_DAV_MAX
38 WFM2_UMOUNT_FAIL
39 WFM2_MOUNT_FAIL
40 WFM2_WEBDAV_ACCOUNT_PASSWD_ERROR
41 WFM2_WEBDAV_SSL_ERROR
42 WFM2_WEBDAV_REMOUNT_ERROR
43 WFM2_WEBDAV_HOST_ERROR
44 WFM2_WEBDAV_TIMEOUT_ERROR
45 WFM2_WEBDAV_CONF_ERROR
46 WFM2_WEBDAV_BASE_ERROR
