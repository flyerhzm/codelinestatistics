require 'test/unit'

require File.expand_path(File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'html_code')))

class HtmlCode
  def is_script
    @is_script
  end
  
  def is_style
    @is_style
  end
end

class TC_HtmlCodeTest < Test::Unit::TestCase
  
  def setup
    @result = Result.new
    @html_code = HtmlCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_script
    @html_code.parse("<script type=\"text/javascript\">")
    assert @html_code.is_script
    @html_code.parse("<!--")
    @html_code.parse("document.all.forms[0].submit()")
    @html_code.parse("-->")
    @html_code.parse("</script>")
    assert !@html_code.is_script
    assert_equal 5, @result.code_lines
    assert_equal 0, @result.comment_lines
  end
  
  def test_script_one_line
    @html_code.parse("<script type=\"text/javascript\" />")
    assert !@html_code.is_script
    assert_equal 1, @result.code_lines
    assert_equal 0, @result.comment_lines
    
    @html_code.parse("<script type=\"text/javascript\"></script>")
    assert !@html_code.is_script
    assert_equal 2, @result.code_lines
    assert_equal 0, @result.comment_lines		
  end
  
  def test_style
    @html_code.parse("<style type=\"text/css\">")
    assert @html_code.is_style
    @html_code.parse(" abbr ")
    @html_code.parse(" { ")
    @html_code.parse(" font-size: 12px;")
    @html_code.parse(" } ")
    @html_code.parse("</style>")
    assert !@html_code.is_style
    assert_equal 6, @result.code_lines
    assert_equal 0, @result.comment_lines
  end
end