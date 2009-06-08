require File.expand_path(File.join(File.dirname(__FILE__), 'single_line_and_block_comment_code'))

# PhpCode is a parser for a php code file.
class PhpCode < SingleLineAndBlockCommentCode
  def initialize(result)
    super(result, ['#', '\/\/'])
  end
end
