require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'jsp_code'))

class JspCode
  def is_java_code
    @is_java_code
  end
end

class TC_JspCodeTest < Test::Unit::TestCase
  def setup
    @result = Result.new
    @jsp_code = JspCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse_blank
    @jsp_code.parse("\n")
    assert_equal 1, @result.blank_lines
    
    @jsp_code.parse("")
    assert_equal 2, @result.blank_lines
    
    @jsp_code.parse(" ")
    assert_equal 3, @result.blank_lines
  end
  
  def test_parse_single_line_comment
    @jsp_code.parse("<!-- test -->")
    assert_equal 1, @result.comment_lines
    
    @jsp_code.parse("<%-- test --%>")
    assert_equal 2, @result.comment_lines			
  end
  
  def test_parse_multi_line_comment			
    @jsp_code.parse("<!--")
    @jsp_code.parse(" test1")
    @jsp_code.parse(" * test")
    @jsp_code.parse(" test2")
    @jsp_code.parse(" -->")
    assert_equal 5, @result.comment_lines		
    
    @jsp_code.parse("<%--")
    @jsp_code.parse(" test1")
    @jsp_code.parse(" * test")
    @jsp_code.parse(" test2")
    @jsp_code.parse(" --%>")
    assert_equal 10, @result.comment_lines					
  end
  
  def test_parse_comment_with_code
    @jsp_code.parse("<form> <!-- form -->")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    @jsp_code.parse("<form> <!-- form -->")
    assert_equal 2, @result.code_lines			
    
    Configure.set_value(Configure::TRAILING_COMMENT, 2)
    @jsp_code.parse("<form> <!-- form -->")
    assert_equal 2, @result.comment_lines				
    
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
    @jsp_code.parse("<form> <%-- form --%>")
    assert_equal 3, @result.code_lines
    assert_equal 3, @result.comment_lines
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    @jsp_code.parse("<form> <%-- form --%>")
    assert_equal 4, @result.code_lines			
    
    Configure.set_value(Configure::TRAILING_COMMENT, 2)
    @jsp_code.parse("<form> <%-- form --%>")
    assert_equal 4, @result.comment_lines				
  end
  
  def test_parse_java_code
    @jsp_code.parse("<% c = a / b %>")
    assert_equal 1, @result.code_lines
    assert_equal 0, @result.comment_lines
    assert @jsp_code.is_java_code == false
    
    @jsp_code.parse("<%")
    @jsp_code.parse("/* divide */")
    assert @jsp_code.is_java_code
    @jsp_code.parse("c= a / b;")
    @jsp_code.parse("c= a / b; // divide")
    @jsp_code.parse("%>")
    assert_equal 5, @result.code_lines
    assert_equal 2, @result.comment_lines
    assert @jsp_code.is_java_code == false
  end
  
  def test_parse_code
    @jsp_code.parse("<form>")
    assert_equal 1, @result.code_lines
    
    @jsp_code.parse("</form>")
    assert_equal 2, @result.code_lines			
  end
end