require File.expand_path(File.join(File.dirname(__FILE__), 'block_comment_code'))
require File.expand_path(File.join(File.dirname(__FILE__), 'javascript_code'))
require File.expand_path(File.join(File.dirname(__FILE__), 'css_code'))

# HtmlCode is a parser for html code file.
class HtmlCode < BlockCommentCode
  
  def initialize(result, block_comment_begin_symbol = '<!--', block_comment_end_symbol = '-->')
    super(result, block_comment_begin_symbol, block_comment_end_symbol)
    
    @is_script = false
    @is_style = false
    @begin_of_script_regexp = /^\s*<script[^>]*[^\/]>(?!.*<\/)/i
    @end_of_script_regexp = /<\/script>/i
    @begin_of_style_regexp = /^\s*<style/i
    @end_of_style_regexp = /<\/style>/i
    @javascript_code = JavascriptCode.new(result)
    @css_code = CssCode.new(result)
  end
  
  # The parse process, line by line, is as follows:
  # 1. if the @is_script is true, the line must be a code line.
  # 1.1. if the line is end with end of script symbol, the line is code line.
  # 1.2. use JavascriptCode
  # 2.1. if the line is end with end of style symbol, the line is code line.
  # 2.2. use CssCode
  # 3. if the line contains begin of script symbol, the line is a code line and next lines is a script line.
  # 4. if the line contains begin of style symbol, the line is a code line and next lines is a style line.
  # 5. otherwise parse as BlockCommentCode
  def parse(line)
    if @is_script
      if line =~ @end_of_script_regexp
        @is_script = false
        match_code_line
      else
        @javascript_code.parse(line)
      end
    elsif @is_style
      if line =~ @end_of_style_regexp
        @is_style = false
        match_code_line
      else
        @css_code.parse(line)
      end
    else
      if line =~ @begin_of_script_regexp
        @is_script = true
        match_code_line
      elsif line =~ @begin_of_style_regexp
        @is_style = true
        match_code_line
      else
        super(line)
      end
    end
  end
end