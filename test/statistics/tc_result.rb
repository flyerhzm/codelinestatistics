require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/statistics', 'result'))

class TC_ResultTest < Test::Unit::TestCase
	def setup
		@result = Result.new("/home/flyerhzm/Test.java")
	end
	
	def test_file_name
		assert_equal "Test.java", @result.file_name 
	end
	
	def test_dir_name
		assert_equal "/home/flyerhzm", @result.dir_name
	end
	
	def test_file_type
		assert_equal ".java", @result.file_type
	end
end