require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/statistics', 'configure'))

class Configure	
  def self.configuration
    @configuration
  end
  
  def self.file
    @@file
  end
  
  def self.clear
    @configuration = {}
  end
end

class TC_ConfigureTest < Test::Unit::TestCase
  def setup
    Configure.load
    Configure.clear
  end
  
  def test_set_get_value
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
    assert_equal 1, Configure.configuration.length
    assert_equal 0, Configure.get_value(Configure::TRAILING_COMMENT)
    
    Configure.set_value(Configure::JAVA_ANNOTATION, 0)
    assert_equal 2, Configure.configuration.length		
    assert_equal 0, Configure.get_value(Configure::JAVA_ANNOTATION)
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    assert_equal 2, Configure.configuration.length
    assert_equal 1, Configure.get_value(Configure::TRAILING_COMMENT)
  end
  
  def test_dump_load
    Configure.set_value(Configure::TRAILING_COMMENT, 0)
    Configure.set_value(Configure::JAVA_ANNOTATION, 0)
    Configure.dump
    
    Configure.set_value(Configure::TRAILING_COMMENT, 1)
    
    Configure.load
    assert_equal 0, Configure.get_value(Configure::TRAILING_COMMENT)
    assert_equal 0, Configure.get_value(Configure::JAVA_ANNOTATION)
  end
end