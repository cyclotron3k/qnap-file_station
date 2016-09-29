require 'minitest/autorun'
require 'qnap/file_station'
require 'qnap/api_error'

class TestFileStation < Minitest::Test
	def test_argument
		assert_raises ArgumentError do
			Qnap::FileStation.new
		end
	end

	def test_error_code_integrity
		assert_equal (0..46).to_a, Qnap::ApiError::STATUS_CODES.map(&:first)
	end
end
