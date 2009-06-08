require File.expand_path(File.join(File.dirname(__FILE__), '..', 'statistics', 'configure'))

# ParserMap defines the extention association
class ParserMap
  def self.load
    $parser = %w{ *.rb *.rhtml *.yml *.java *.html *.jsp *.properties *.xml *.js *.css *.c *.h *.cpp *.py *.php}
    $parser_map = { "xml" => "html", "rb" => "ruby", "yml" => "yaml", 
      "js" => "javascript", "h" => "cplusplus", "cpp" => "cplusplus", "py" => "python" }
    
    file_mapping = Configure.get_value(Configure::FILE_MAPPING)
    unless file_mapping == 0
      ($parser << file_mapping.keys.collect { |extname| "*." + extname }).flatten!
      $parser_map.merge!(file_mapping)
    end
  end	
end