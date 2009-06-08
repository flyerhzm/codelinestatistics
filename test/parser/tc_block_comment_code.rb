require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'block_comment_code'))

class BlockCommentCode
  def is_comment
    @is_comment
  end
end

class TC_BlockCommentCodeTest < Test::Unit::TestCase
  def setup
    @result = Result.new
    @html_code = BlockCommentCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse_blank
    @html_code.parse("\n")
    assert_equal 1, @result.blank_lines
    
    @html_code.parse("")
    assert_equal 2, @result.blank_lines
    
    @html_code.parse(" ")
    assert_equal 3, @result.blank_lines
  end
  
  def test_parse_single_line_comment
    @html_code.parse("<!-- test -->")
    assert_equal 1, @result.comment_lines
  end
  
  def test_parse_multi_line_comment			
    @html_code.parse("<!--")
    @html_code.parse(" test1")
    @html_code.parse(" * test")
    @html_code.parse(" test2")
    @html_code.parse(" -->")
    assert_equal 5, @result.comment_lines		
  end
  
  def test_parse_trailing_comment
    @html_code.parse("<html> <!-- multiply -->")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    @html_code.parse("<html> <!-- multiply -->")
    assert_equal 2, @result.code_lines			
    
    Configure.set_value(Configure::TRAILING_COMMENT, 2)
    @html_code.parse("<html> <!-- multiply -->")
    assert_equal 2, @result.comment_lines				
  end
  
  def test_parse_trailing_block_comment
    @html_code.parse("<html> <!-- multiply")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    assert @html_code.is_comment
  end
  
  def test_parse_code
    @html_code.parse("<html>")
    assert_equal 1, @result.code_lines
    
    @html_code.parse("</html>")
    assert_equal 2, @result.code_lines			
  end
end