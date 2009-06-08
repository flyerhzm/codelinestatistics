require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'css_code'))

class TC_CssCodeTest < Test::Unit::TestCase

  def setup
    @result = Result.new
    @css_code = CssCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse
    @css_code.parse("/* basic elements */")
    @css_code.parse("html {")
    @css_code.parse(" margin: 0px;")
    @css_code.parse(" padding: 0px;")
    @css_code.parse("}")
    assert_equal 1, @result.comment_lines
    assert_equal 4, @result.code_lines
  end
end