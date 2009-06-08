require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'rhtml_code'))

class RhtmlCode
  def is_ruby_code
    @is_ruby_code
  end
end

class TC_RhtmlCodeTest < Test::Unit::TestCase
  def setup
    @result = Result.new
    @rhtml_code = RhtmlCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse_blank
    @rhtml_code.parse("\n")
    assert_equal 1, @result.blank_lines
    
    @rhtml_code.parse("")
    assert_equal 2, @result.blank_lines
    
    @rhtml_code.parse(" ")
    assert_equal 3, @result.blank_lines
  end
  
  def test_parse_single_line_comment
    @rhtml_code.parse("<!-- test -->")
    assert_equal 1, @result.comment_lines
  end
  
  def test_parse_multi_line_comment			
    @rhtml_code.parse("<!--")
    @rhtml_code.parse(" test1")
    @rhtml_code.parse(" * test")
    @rhtml_code.parse(" test2")
    @rhtml_code.parse(" -->")
    assert_equal 5, @result.comment_lines			
  end
  
  def test_parse_comment_with_code
    @rhtml_code.parse("<form> <!-- form -->")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    @rhtml_code.parse("<form> <!-- form -->")
    assert_equal 2, @result.code_lines			
    
    Configure.set_value(Configure::TRAILING_COMMENT, 2)
    @rhtml_code.parse("<form> <!-- form -->")
    assert_equal 2, @result.comment_lines				
  end
  
  def test_parse_ruby_code
    @rhtml_code.parse("<% c = a / b %>")
    assert_equal 1, @result.code_lines
    assert_equal 0, @result.comment_lines
    assert @rhtml_code.is_ruby_code == false
    
    @rhtml_code.parse("<%")
    @rhtml_code.parse("# divide")
    assert @rhtml_code.is_ruby_code
    @rhtml_code.parse("c= a / b;")
    @rhtml_code.parse("c= a / b; # divide")
    @rhtml_code.parse("%>")
    assert_equal 5, @result.code_lines
    assert_equal 2, @result.comment_lines
    assert @rhtml_code.is_ruby_code == false
  end
  
  def test_parse_code
    @rhtml_code.parse("<form>")
    assert_equal 1, @result.code_lines
    
    @rhtml_code.parse("</form>")
    assert_equal 2, @result.code_lines			
  end
end