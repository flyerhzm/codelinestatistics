require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'php_code'))

class TC_PhpCodeTest < Test::Unit::TestCase
  def setup
    @result = Result.new
    @php_code = PhpCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end

  def test_parse_single_line_comment
    @php_code.parse("// test")
    assert_equal 1, @result.comment_lines

    @php_code.parse("# test")
    assert_equal 2, @result.comment_lines
  end

  def test_parse_block_comment
    @php_code.parse("/*")
    @php_code.parse("test1")
    @php_code.parse("test2")
    @php_code.parse("test3")
    @php_code.parse("*/")
    assert_equal 5, @result.comment_lines
  end

  def test_parse_code_line
    @php_code.parse("c = a / b")
    assert_equal 1, @result.code_lines
  end

  def test_parse_trailing_comment
    @php_code.parse("c = a / b // multiply")
    assert_equal 1, @result.comment_lines
    assert_equal 1, @result.code_lines
  end
end