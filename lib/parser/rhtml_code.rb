require File.expand_path(File.join(File.dirname(__FILE__), 'html_code'))
require File.expand_path(File.join(File.dirname(__FILE__), 'ruby_code'))

# RhtmlCode is a parser for Rhtml code file.
class RhtmlCode < HtmlCode
  
  def initialize(result)
    super(result)
    @is_ruby_code = false
    @single_line_ruby_code_regexp = /^\s*<%.*%>\s*$/
    @begin_of_ruby_code_regexp = /^\s*<%/
    @end_of_ruby_code_regexp = /%>\s*$/
    @ruby_code = RubyCode.new(result)
  end
  
  # The parse process, line by line, is as follows:
  # 1. if the @is_ruby_code, the line must be a ruby code
  # 1.1. if the line is end with end of ruby code symbol, the line is a code line
  # 1.2. use RubyCode
  # 2. if the line contains single line ruby code symbol, the line is a code line
  # 3. if the line begins with begin of ruby code symbol, the line is a code line
  # 4. otherwise use HtmlCode
  def parse(line)
    if @is_ruby_code
      if line =~ @end_of_ruby_code_regexp
        @is_ruby_code = false
        match_code_line
      else
        @ruby_code.parse(line)
      end
    else
      if line =~ @single_line_ruby_code_regexp
        match_code_line
      elsif line =~ @begin_of_ruby_code_regexp
        @is_ruby_code = true
        match_code_line
      else
        super(line)
      end
    end
  end
end