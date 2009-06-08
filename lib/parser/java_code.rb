require File.expand_path(File.join(File.dirname(__FILE__), 'single_line_and_block_comment_code'))

# JavaCode is a parser for java code file.
class JavaCode < SingleLineAndBlockCommentCode
  
  def initialize(result)
    super(result)
    @annotation_regexp = /^\s*@/
  end
  
  # The parse process, line by line, is as follows:
  # 1. if the line begin with annotation symbol, the line is a annotation line.
  # 2. otherwise use SingleLineAndBlockCommentCode
  def parse(line)
    if line =~ @annotation_regexp
      match_annotation
    else
      super(line)
    end		
  end
  
  def match_annotation
    case Configure.get_value(Configure::JAVA_ANNOTATION)
    when 0 then @result.add_code_lines
    when 1 then @result.add_comment_lines
    end
  end
end