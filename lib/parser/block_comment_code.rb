require File.expand_path(File.join(File.dirname(__FILE__), 'code_parser'))

# BlockCommentCode is a parser for the source codes that have only block-style comments.
# Default block comments are between \<!-- and -->.
class BlockCommentCode  < CodeParser
  
  def initialize(result, block_comment_begin_symbol = '<!--', block_comment_end_symbol = '-->')
    super(result, '', block_comment_begin_symbol, block_comment_end_symbol)
  end
  
  # The parse process, line by line, is as follows:
  # 1. if it is a blank line
  # 2. if the @is_comment is true, the line must be a comment line
  # 2.1. if the line is end of block comment
  # 2.2. the line is middle of block comment
  # 3. if the line is a single-line comment, like \<!--  -->
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
        if line =~ @single_line_comment_regexp[1]
          match_single_line_comment
        elsif line =~ @begin_of_block_comment_regexp
          match_beginning_of_multi_line_comment
        elsif line =~ @maybe_block_comment_regexp
          match_maybe_block_comment(line)
        else
          match_code_line
        end
      end
    end		
  end
end