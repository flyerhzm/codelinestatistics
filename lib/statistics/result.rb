require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper', 'readable'))

# Result is to keep track of the file's statistics about total lines, code line, 
# comment lines, blank lines and so on.
class Result
  include Readable

  attr_accessor :file, :total_lines, :code_lines, :comment_lines, :blank_lines
  
  def initialize(file = nil)
    @file = file;
    @total_lines = 0;
    @code_lines = 0;
    @comment_lines = 0;
    @blank_lines = 0;
  end
  
  def file_name
    if (@file)
      File.basename(@file)
    else 
      nil
    end
  end
  
  def dir_name
    if (@file)
      File.dirname(@file)
    else 
      nil
    end
  end
  
  def file_type
    if (@file)
      File.extname(@file)
    else 
      nil
    end
  end
  
  def readable_total_lines
    readable_size(@total_lines)
  end
  
  def readable_code_lines
    readable_size(@code_lines)
  end
  
  def readable_comment_lines
    readable_size(@comment_lines)
  end
  
  def readable_blank_lines
    readable_size(@blank_lines)
  end
  
  def add_total_lines
    @total_lines += 1
  end
  
  def add_code_lines
    @code_lines += 1
  end
  
  def add_comment_lines
    @comment_lines += 1
  end
  
  def add_blank_lines
    @blank_lines += 1
  end
  
  def to_s
		  "file: #{file}, total_lines: #{total_lines}, code_lines: #{code_lines}, comment_lines: #{comment_lines}, blank_lines: #{blank_lines}"
  end
end