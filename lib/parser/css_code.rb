require File.expand_path(File.join(File.dirname(__FILE__), 'block_comment_code'))

# CssCode is a parser for a css code file.
class CssCode < BlockCommentCode
  def initialize(result)
    super(result, '\/\*', '\*\/')
  end
end