require 'minitest/autorun'
require 'qnap/file_station'

class TestFileStation < Minitest::Test
	def test_argument
		assert_raises ArgumentError do
			Qnap::FileStation.new
		end
	end
end
