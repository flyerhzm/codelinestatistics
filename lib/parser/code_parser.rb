require File.expand_path(File.join(File.dirname(__FILE__), '..', 'statistics', 'configure'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'statistics', 'result'))

# CodeParser is the base parser for all source codes. It defines what should be done when matching a code line, 
# comment line and blank line. Every parser has a result object which keeps all the statistics infos.
class CodeParser
  def initialize(result, single_line_comment_symbol = '\/\/', block_comment_begin_symbol = '\/\*', block_comment_end_symbol = '\*\/')
    @is_comment = false  # true if the line is comment
    @result = result
    @blank_line_regexp = /^\s*$/
    single_line_comment_symbols = single_line_comment_symbol.class == String ? [single_line_comment_symbol] : single_line_comment_symbol

    @single_line_comment_symbols = single_line_comment_symbols.collect{|symbol| symbol.gsub('\\', '')}
    @block_comment_begin_symbol = block_comment_begin_symbol.gsub('\\', '')
    @block_comment_end_symbol = block_comment_end_symbol.gsub('\\', '')
    
    @single_line_comment_regexp = [single_line_comment_symbol.class == String ? Regexp.new("^\s*#{single_line_comment_symbol}") : Regexp.new("^\s*(#{single_line_comment_symbol.join('|')})"), Regexp.new("^\s*#{block_comment_begin_symbol}.*#{block_comment_end_symbol}\s*$")]
    @begin_of_block_comment_regexp = Regexp.new("^\s*#{block_comment_begin_symbol}")
    @end_of_block_comment_regexp = Regexp.new("#{block_comment_end_symbol}\s*$")
    @maybe_single_line_comment_regexp = single_line_comment_symbol.class == String ? Regexp.new(single_line_comment_symbol) : Regexp.new(single_line_comment_symbol.join('|'))
    @maybe_block_comment_regexp = Regexp.new(block_comment_begin_symbol)
  end
  
  def match_blank_line
    @result.add_blank_lines
  end
  
  def match_single_line_comment
    @result.add_comment_lines
  end
  
  def match_beginning_of_multi_line_comment
    @result.add_comment_lines
    @is_comment = true
  end
  
  def match_end_of_multi_line_comment
    @result.add_comment_lines
    @is_comment = false
  end
  
  def match_middle_of_multi_line_comment
    @result.add_comment_lines
  end
  
  def match_code_line
    @result.add_code_lines
  end
  
  # Trailing comment can be only a code line, only a comment line and a code line and a comment line.
  def match_trailing_comment
    case Configure.get_value(Configure::TRAILING_COMMENT)
    when 0
      @result.add_code_lines
      @result.add_comment_lines
    when 1 then 
      @result.add_code_lines
    when 2 then 
      @result.add_comment_lines
    end
  end	
  
  # The line contain a single line comment symbol, but the symbol may be in the string,
  # so the line can be a trailing comment line or a code line
  def match_maybe_single_line_comment(line)
    is_string = false # if the char is in a string
    is_ignore = false # ignore the char just after the '\'
    @single_line_comment_symbols.each do |single_line_comment_symbol|
      single_line_comment_length = single_line_comment_symbol.length
       (0...line.length).each do |index|
        if is_ignore
          is_ignore = false
        else
          case line[index, 1]
          when '"'
            is_string = !is_string
          when '\\'
            is_ignore = true
          else
            unless is_string
              if line[index, single_line_comment_length] == single_line_comment_symbol
                match_trailing_comment
                return
              end
            end
          end
        end
      end
    end
    match_code_line
  end
  
  # The line contain a begin of block comment, but the symbol may be in the string, 
  # so the line can be a trailing comment line or a code line.
  def match_maybe_block_comment(line)
    is_string = false # if the char is in a string
    is_ignore = false # ignore the char just after the '\'
    is_match = false
    block_comment_end_length = @block_comment_end_symbol.length
    block_comment_begin_length = @block_comment_begin_symbol.length
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
            if @is_comment && line[index, block_comment_end_length] == @block_comment_end_symbol
              @is_comment = false
            end
            if !@is_comment && line[index, block_comment_begin_length] == @block_comment_begin_symbol
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