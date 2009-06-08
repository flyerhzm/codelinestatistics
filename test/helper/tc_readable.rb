require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/helper', 'readable'))

class TC_ReadableTest < Test::Unit::TestCase
  include Readable
  
  def test_number_precision
    assert_equal "1", number_precision(1.249, 0)
    assert_equal "1.2", number_precision(1.249, 1)
    assert_equal "1.25", number_precision(1.249, 2)
    
    assert_equal("-1", number_precision(-1.249, 0))
    assert_equal("-1.2", number_precision(-1.249, 1))
    assert_equal("-1.25", number_precision(-1.249, 2))
  end
  
  def test_number_to_percentage
    assert_equal "10%", number_to_percentage(10, 0)
    assert_equal "10.1%", number_to_percentage(10.12, 1)
  end
  
  def test_readable_file_size
    assert_equal '1 Byte', readable_file_size(1, 0)
    assert_equal '1 KB', readable_file_size(1024, 0)
    assert_equal '1 MB', readable_file_size(1024*1024, 0)
    assert_equal '1 GB', readable_file_size(1024*1024*1024, 0)
  end
  
  def test_readable_size
    assert_equal '10', readable_size(10)
    assert_equal '100', readable_size(100)
    assert_equal '1,000', readable_size(1000)
    assert_equal '10,000', readable_size(10000)
    assert_equal '100,000', readable_size(100000)
    assert_equal '1,000,000', readable_size(1000000)
  end
  
end