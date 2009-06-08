require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'single_line_and_block_comment_code'))

class SingleLineAndBlockCommentCode
  def is_comment
    @is_comment
  end
  
  def is_comment=(other)
    @is_comment = other
  end
end

class TC_SingleLineAndBlockCommentCodeTest < Test::Unit::TestCase
  
  def setup
    @result = Result.new
    @java_code = SingleLineAndBlockCommentCode.new(@result)
    Configure.load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
  end
  
  def test_parse_blank
    @java_code.parse("\n")
    assert_equal 1, @result.blank_lines
    
    @java_code.parse("")
    assert_equal 2, @result.blank_lines
    
    @java_code.parse(" ")
    assert_equal 3, @result.blank_lines
  end
  
  def test_parse_single_line_comment
    @java_code.parse("// test")
    assert_equal 1, @result.comment_lines
    
    @java_code.parse("/* test */")
    assert_equal 2, @result.comment_lines
    
    @java_code.parse("/** test */")
    assert_equal 3, @result.comment_lines
  end
  
  def test_parse_multi_line_comment
    @java_code.parse("/**")
    @java_code.parse("  *")
    @java_code.parse("  * test")
    @java_code.parse("  *")
    @java_code.parse("  */")
    assert_equal 5, @result.comment_lines
    
    @java_code.parse("/*")
    @java_code.parse(" *")
    @java_code.parse(" * test")
    @java_code.parse(" *")
    @java_code.parse(" */")
    assert_equal 10, @result.comment_lines		
    
    @java_code.parse("/*")
    @java_code.parse(" test1")
    @java_code.parse(" * test")
    @java_code.parse(" test2")
    @java_code.parse(" */")
    assert_equal 15, @result.comment_lines		
  end
  
  def test_parse_trailing_comment
    @java_code.parse("c = a / b; // divide")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    @java_code.parse("c = a / b; /* divide */")
    assert_equal 2, @result.code_lines
    assert_equal 2, @result.comment_lines
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    @java_code.parse("c = a / b; // divide")
    assert_equal 3, @result.code_lines			
    
    Configure.set_value(Configure::TRAILING_COMMENT, 2)
    @java_code.parse("c = a / b; // divide")
    assert_equal 3, @result.comment_lines				
  end
  
  def test_parse_trailing_block_comment
    @java_code.parse("c = a / b; /* divide")
    assert_equal 1, @result.code_lines
    assert_equal 1, @result.comment_lines
    assert @java_code.is_comment
    
    @java_code.is_comment = false
    @java_code.parse("c = a / b; /** divide")
    assert_equal 2, @result.code_lines
    assert_equal 2, @result.comment_lines
    assert @java_code.is_comment
  end
  
  def test_parse_code
    @java_code.parse("c=a*b")
    assert_equal 1, @result.code_lines
  end
  
  def test_comment_in_string
    @java_code.parse("System.out.println(\"//hello\");")
    assert_equal 1, @result.code_lines
    assert_equal 0, @result.comment_lines
    
    @java_code.parse("System.out.println(\"\\\"//hello\");")
    assert_equal 2, @result.code_lines
    assert_equal 0, @result.comment_lines
    
    @java_code.parse("System.out.println(\"\\\"//hello\");  // hello")
    assert_equal 3, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    @java_code.parse("System.out.println(\"/* hello */\");")
    assert_equal 4, @result.code_lines
    assert_equal 1, @result.comment_lines
    
    @java_code.parse("System.out.println(\"/* hello */\");  /* hello */")
    assert_equal 5, @result.code_lines
    assert_equal 2, @result.comment_lines
    
    @java_code.parse("System.out.println(\"/** hello */\");")
    assert_equal 6, @result.code_lines
    assert_equal 2, @result.comment_lines
    
    @java_code.parse("System.out.println(\"/** hello */\");  /** hello */")
    assert_equal 7, @result.code_lines
    assert_equal 3, @result.comment_lines
  end
  
  def test_parse_special
    @java_code.parse("/**")
    @java_code.parse("* {@link http://developer.java.sun.com/developer/restricted/patterns/ServiceLocator.html}")
    @java_code.parse("*/")
    assert_equal 3, @result.comment_lines
    assert_equal 0, @result.code_lines
  end
end