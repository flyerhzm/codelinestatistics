require File.expand_path(File.join(File.dirname(__FILE__), 'single_line_comment_code'))

# RubyCode is a parser for ruby code file.
class RubyCode < SingleLineCommentCode
  
  def initialize(result)
    super(result)
    @is_comment = false
    @begin_of_block_comment_regexp = /^\s*=begin\s*$/i
    @end_of_block_comment_regexp = /^\s*=end\s*$/i
  end
  
  # The parse process, line by line, is as follows:
  # 1. if the @is_commet is true, the line must be a comment line
  # 1.1. if the line is end of block comment
  # 1.2. the line is middle of block comment
  # 2. if the line is begin of block line comment
  # 3. otherwise it is a code line
  def parse(line)
    if @is_comment
      if line =~ @end_of_block_comment_regexp
        match_end_of_multi_line_comment
      else
        match_middle_of_multi_line_comment
      end
    else
      if line =~ @begin_of_block_comment_regexp
        match_beginning_of_multi_line_comment
      else 
        super(line)
      end
    end
  end
end