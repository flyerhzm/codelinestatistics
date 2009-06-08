require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'ruby_code'))

class TC_RubyCodeTest < Test::Unit::TestCase
  def setup
    @result = Result.new
    @ruby_code = RubyCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse_single_line_comment
    @ruby_code.parse("# test")
    assert_equal 1, @result.comment_lines
  end
  
  def test_parse_block_comment
    @ruby_code.parse("=begin")
    @ruby_code.parse("test1")
    @ruby_code.parse("test2")
    @ruby_code.parse("test3")
    @ruby_code.parse("=end")
    assert_equal 5, @result.comment_lines
  end
  
  def test_parse_code_line
    @ruby_code.parse("c = a / b")
    assert_equal 1, @result.code_lines
  end
  
  def test_parse_trailing_comment
    @ruby_code.parse("c = a / b # multiply")
    assert_equal 1, @result.comment_lines
    assert_equal 1, @result.code_lines
  end
end