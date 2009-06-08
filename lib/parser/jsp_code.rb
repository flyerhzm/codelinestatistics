require File.expand_path(File.join(File.dirname(__FILE__), 'html_code'))
require File.expand_path(File.join(File.dirname(__FILE__), 'java_code'))

# JspCode is a parser for jsp code file.
class JspCode < HtmlCode
  
  def initialize(result)
    super(result, '<[!%]--', '--%?>')
    @block_comment_begin_symbol = ['<!--', '<%--']
    @block_comment_end_symbol = ['-->', '--%>']
    
    @is_java_code = false
    @single_line_java_code_regexp = /^\s*<%(?![-@]).*%>\s*$/
    @begin_of_java_code_regexp = /^\s*<%(?![-@])/
    @end_of_java_code_regexp = /%>\s*$/
    @java_code = JavaCode.new(result)
  end
  
  # The parse process, line by line, is as follows:
  # 1. if the @is_java_code is true, the line must be a java code
  # 1.1. if the line is end with end of java code symbol, the line is a code line
  # 1.2. use JavaCode
  # 2. if the line contains single line java code symbol, the line is a code line
  # 3. if the line begins with begin of java code symbol, the line is a code line
  # 4. otherwise use HtmlCode
  def parse(line)
    if @is_java_code
      if line =~ @end_of_java_code_regexp
        @is_java_code = false
        match_code_line
      else
        @java_code.parse(line)
      end
    else
      if line =~ @single_line_java_code_regexp
        match_code_line
      elsif line =~ @begin_of_java_code_regexp
        @is_java_code = true
        match_code_line
      else
        super(line)
      end
    end		
  end	
  
  def match_maybe_block_comment(line)
    is_string = false # if the char is in a string
    is_ignore = false # ignore the char just after the '\'
    is_match = false
    match_index = 0;
     (0...line.length).each do |index|
      if is_ignore
        is_ignore = false
      else
        case line[index, 1]
        when '"'
          unless @is_comment
            is_string = !is_string
            is_ignore = false 
          end
        when '\\' 
          is_ignore = true
        else
          unless is_string
            if (@is_comment && ((match_index == 0 && line[index, 3] == @block_comment_end_symbol[0]) || (match_index == 1 && line[index, 4]  == @block_comment_end_symbol[1])))
              @is_comment = false
            end
            if (!@is_comment && (line[index, 4] == @block_comment_begin_symbol[0] || line[index, 4] == @block_comment_begin_symbol[1]))
              if line[index, 4] == @block_comment_begin_symbol[0]
                match_index = 0
              else
                match_index = 1
              end
              match_trailing_comment unless is_match
              is_match = true
              @is_comment = true
            end
          end
          is_ignore = false 
        end
      end
    end
    match_code_line unless is_match
  end
end