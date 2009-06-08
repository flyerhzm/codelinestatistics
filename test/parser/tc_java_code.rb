require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'java_code'))

class TC_JavaCodeTest < Test::Unit::TestCase
  
  def setup
    @result = Result.new
    @java_code = JavaCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
    Configure.set_value(Configure::JAVA_ANNOTATION, 0)
  end
  
  def test_parse_annotation
    @java_code.parse(" @Runtime")
    assert_equal 1, @result.code_lines
    
    Configure.set_value(Configure::JAVA_ANNOTATION, 1)
    @java_code.parse(" @Runtime")
    assert_equal 1, @result.comment_lines
  end
end