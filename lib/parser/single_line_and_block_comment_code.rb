require File.expand_path(File.join(File.dirname(__FILE__), 'code_parser'))

# SingleLineAndBlockCommentCode is a parser for the source codes that have both single line comments and block comments.
# Default single line comments are begin with // and default block comments are between /* and */
class SingleLineAndBlockCommentCode < CodeParser
  
  def initialize(result, single_line_comment_symbol = '\/\/', block_comment_begin_symbol = '\/\*', block_comment_end_symbol = '\*\/')
    super(result, single_line_comment_symbol, block_comment_begin_symbol, block_comment_end_symbol)
  end
  
  # The process, line by line, is as follow:
  # 1. if it is a blank line
  # 2. if the @is_comment is true, the line must be a comment line
  # 2.1. if the line is end of block comment
  # 2.2. the line is middle of block comment
  # 3. if it is a single line comment, like // or /*...*/
  # 4. if the line is begin of block comment
  # 5. if the begin of line comment not appears begin of the line, it may be a block comment
  # 6. otherwise it is a code line
  def parse(line)
    if line =~ @blank_line_regexp
      match_blank_line
    else
      if @is_comment
        if line =~ @end_of_block_comment_regexp
          match_end_of_multi_line_comment
        else
          match_middle_of_multi_line_comment
        end
      else
        if line =~ @single_line_comment_regexp[0] || line =~ @single_line_comment_regexp[1]
          match_single_line_comment
        elsif line =~ @begin_of_block_comment_regexp
          match_beginning_of_multi_line_comment
        elsif line =~ @maybe_single_line_comment_regexp
          match_maybe_single_line_comment(line)
        elsif line =~ @maybe_block_comment_regexp
          match_maybe_block_comment(line)
        else
          match_code_line
        end
      end
    end
  end
end