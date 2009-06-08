require 'yaml'

# Configure let user to customize the parse process about trailing comment and java annotation.
# It must be initialized once the application is starting, called Configure.load
class Configure	
  
  TRAILING_COMMENT = :trailing_comment
  
  TRAILING_COMMENT_VALUE = { "one code line and one comment line" => 0, "only one code line" => 1, "only one comment line" => 2 }
  
  JAVA_ANNOTATION = :java_annotation
  
  JAVA_ANNOTATION_VALUE = { "code line" => 0, "comment line" => 1 }
  
  FILE_MAPPING = :file_mapping
  
  FILE = "configuration.yml"
  
  def self.dump
    File.open(FILE, 'w') { |f| YAML.dump(@configuration, f) }
  end
  
  def self.load
    begin
      File.open(FILE, 'r') { |f| @configuration = YAML.load(f) }
    rescue SystemCallError
    		@configuration = {}
    end
  end
  
  def self.set_hash(symbol, value)
    @configuration[symbol] = value
  end
  
  def self.get_hash(symbol)
    @configuration[symbol] || {}
  end
  
  def self.set_value(symbol, value)
    @configuration[symbol] = value
  end
  
  def self.get_value(symbol)
    @configuration[symbol] || 0
  end
end