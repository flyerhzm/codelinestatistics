require File.expand_path(File.join(File.dirname(__FILE__), 'lib/view', 'statistics_window'))
require File.expand_path(File.join(File.dirname(__FILE__), 'lib/statistics', 'configure'))
require File.expand_path(File.join(File.dirname(__FILE__), 'lib/parser', 'parser_map'))

# Start of the application. 
Configure.load
ParserMap.load

application = FXApp.new
StatisticsWindow.new(application)
application.create
application.run