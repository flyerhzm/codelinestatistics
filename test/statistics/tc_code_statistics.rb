require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/statistics', 'code_statistics'))
require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/statistics', 'configure'))
require File.expand_path(File.join(File.dirname(__FILE__), '../..', 'lib/parser', 'parser_map'))

class TC_CodeStatisticsTest < Test::Unit::TestCase

  def setup
    @code_statistics = CodeStatistics.new
    @result = Result.new
    Configure.load
    ParserMap.load
  end

  def test_create_parser
    assert_instance_of JavaCode, @code_statistics.create_parser('Test.java', @result)
  end
end