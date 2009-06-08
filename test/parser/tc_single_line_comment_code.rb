require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'single_line_comment_code'))

class TC_SingleLineCommentCodeTest < Test::Unit::TestCase
  def setup
    @result = Result.new
    @properties_code = SingleLineCommentCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse_blank
    @properties_code.parse("\n")
    assert_equal 1, @result.blank_lines
    
    @properties_code.parse("")
    assert_equal 2, @result.blank_lines
    
    @properties_code.parse(" ")
    assert_equal 3, @result.blank_lines
  end
  
  def test_parse_single_line_comment
    @properties_code.parse("# test")
    assert_equal 1, @result.comment_lines
  end
  
  def test_parse_comment_with_code
    @properties_code.parse("c=a*b # multiply ")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    @properties_code.parse("c=a*b # multiply ")
    assert_equal 2, @result.code_lines			
    
    Configure.set_value(Configure::TRAILING_COMMENT, 2)
    @properties_code.parse("c=a*b # multiply ")
    assert_equal 2, @result.comment_lines				
  end
  
  def test_parse_code
    @properties_code.parse("test")
    assert_equal 1, @result.code_lines
    
    @properties_code.parse("test")
    assert_equal 2, @result.code_lines			
  end
end