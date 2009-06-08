require File.expand_path(File.join(File.dirname(__FILE__), 'code_parser'))

# SingleLineCommentCode is a parser for the source codes that have only single-style comments.
# Default single line comments are begin with #
class SingleLineCommentCode < CodeParser
  
  def initialize(result, comment_symbol = '#')
    super(result, comment_symbol)
  end
  
  # The parse process, line by line, is as follows:
  # 1. if it is a blank line
  # 2. if it is a single line comment line
  # 3. if it may be a trailing line comment line
  # 4. otherwise it is a code line
  def parse(line)
    if line =~ @blank_line_regexp
      match_blank_line
    elsif line =~ @single_line_comment_regexp[0]
      match_single_line_comment
    elsif line =~ @maybe_single_line_comment_regexp
      match_trailing_comment
    else
      match_code_line
    end
  end
end