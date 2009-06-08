require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'c_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'cplusplus_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'css_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'html_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'java_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'javascript_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'jsp_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'properties_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'ruby_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'rhtml_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'yaml_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'python_code'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'parser', 'php_code'))
require File.expand_path(File.join(File.dirname(__FILE__), 'result'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper', 'readable'))

require 'find'

# CodeStatistics
class CodeStatistics
  include Readable

  attr_reader :results, :is_comment, :is_scanning, :base_dir 
  
  def initialize
    @is_comment = false
    @is_scanning = false
    @results = []		
  end

  # Scan the file
  def scan_file(file)
    count(file)
  end
  
  # Scan all files under the dir directory and parse the files that match file_types.
  # If contain_subdirectory is true, it will scan the subdirectories recursively.
  def scan_direcotry(dir, file_types, contain_subdirectory)
    @results = []
    @base_dir = dir
    @is_scanning = true
    if contain_subdirectory
      Find.find(dir) do |path|
        match_file(file_types, path)
      end
    else
      Dir.foreach(dir) do |file_name|
        match_file(file_types, File.join(dir, file_name))
      end
    end
    @is_scanning = false
  end
  
  # Check if the file match file_types.
  def match_file(file_types, file)
    file_types.each do |file_type|
      if File.fnmatch(file_type, File.basename(file))
        count(file)
      end
    end
  end
  
  # Count the code line about the file with filename, add the result to @results.
  def count(filename)
    result = Result.new(filename.gsub(File::SEPARATOR, File::ALT_SEPARATOR || File::SEPARATOR))
    parser = create_parser(filename, result)
    IO.foreach(filename) do |line|
      result.add_total_lines
      parser.parse(line)
    end
    @results << result
  end
  
  # Create a parser for different file with filename.
  def create_parser(filename, result)
    extend_name = File.extname(filename)[1..-1]
    while $parser_map[extend_name]
      extend_name = $parser_map[extend_name]
    end
    
    file_mapping = Configure.get_hash(Configure::FILE_MAPPING)
    extend_name = file_mapping[extend_name] || extend_name
    Object.const_get("#{extend_name.capitalize}Code").new(result)
  end
  
  def total_files
    @results.length
  end
  
  def readable_total_files
    readable_size(total_files)
  end
  
  def total_size
    sum = 0
    @results.each do |result|
      sum += File.size(result.file)
    end
    sum
  end
  
  def readable_total_size
    readable_file_size(total_size, 1)
  end
  
  def total_lines
    sum = 0
    @results.each do |result|
      sum += result.total_lines
    end
    sum
  end
  
  def readable_total_lines
    readable_size(total_lines)
  end
  
  def code_lines
    sum = 0
    @results.each do |result|
      sum += result.code_lines
    end
    sum
  end
  
  def readable_code_lines
    readable_size(code_lines)
  end
  
  def comment_lines
    sum = 0
    @results.each do |result|
      sum += result.comment_lines
    end
    sum
  end
  
  def readable_comment_lines
    readable_size(comment_lines)
  end
  
  def blank_lines
    sum = 0
    @results.each do |result|
      sum += result.blank_lines
    end
    sum
  end
  
  def readable_blank_lines
    readable_size(blank_lines)
  end
  
  def code_line_percentage
    number_to_percentage((code_lines * 100).to_f / total_lines, 2)
  end
  
  def comment_line_percentage
    number_to_percentage((comment_lines * 100).to_f / total_lines, 2)
  end
  
  def blank_line_percentage
    number_to_percentage((blank_lines * 100).to_f / total_lines, 2)
  end
end