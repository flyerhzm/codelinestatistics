begin
  require 'fox16'
rescue LoadError => no_fox_err
  begin
    require 'rubygems'
    require 'fox16'
  rescue LoadError
    raise no_fox_err
  end
end
include Fox

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'statistics', 'code_statistics'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper', 'output'))
require File.expand_path(File.join(File.dirname(__FILE__), 'about_dialog'))
require File.expand_path(File.join(File.dirname(__FILE__), 'setting_dialog'))

# StatisticsWindow is the main window for the project.
class StatisticsWindow < FXMainWindow
  
  TIMEOUT = 1000
  
  def initialize(app)
    super(app, "Code Line Statistics")
    
    setIcon(load_icon("statistics"))
    @results_index = 0
    get_tool_bar
    get_contents
  end
  
  def get_contents
    @contents = FXVerticalFrame.new(self, LAYOUT_SIDE_TOP | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    get_select_groupbox
    get_result_table
    get_result_groupbox
    get_progressbar
  end
  
  def get_select_groupbox
    select_groupbox = FXGroupBox.new(@contents, "Select", GROUPBOX_NORMAL | LAYOUT_FILL_X | FRAME_GROOVE)
    select_matrix = FXMatrix.new(select_groupbox, 3, MATRIX_BY_COLUMNS | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    FXLabel.new(select_matrix, "Files: ")
    @file_name = FXDataTarget.new("")
    FXTextField.new(select_matrix, 50, @file_name, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    select_file_button = FXButton.new(select_matrix, "...", nil, nil, 0, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT)
    select_file_button.connect(SEL_COMMAND, method(:on_select_file)) 
    
    FXFrame.new(select_matrix, LAYOUT_FILL_COLUMN|LAYOUT_FILL_ROW)
    @file_types = []
    @file_types_matrix = FXMatrix.new(select_matrix, 5, MATRIX_BY_COLUMNS | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    $parser.each do |file_type|
      dt = FXDataTarget.new(0)
      @file_types << dt
      FXCheckButton.new(@file_types_matrix, file_type, dt, FXDataTarget::ID_VALUE)
    end
    FXFrame.new(select_matrix, LAYOUT_FILL_COLUMN|LAYOUT_FILL_ROW)
    
    FXLabel.new(select_matrix, "Directory: ")
    @directory_name = FXDataTarget.new("")
    FXTextField.new(select_matrix, 50, @directory_name, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    select_directory_button = FXButton.new(select_matrix, "...", nil, nil, 0, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT)
    select_directory_button.connect(SEL_COMMAND, method(:on_select_directory))
    
    FXFrame.new(select_matrix, LAYOUT_FILL_COLUMN|LAYOUT_FILL_ROW)
    @is_subdirectory = FXDataTarget.new(1)
    FXCheckButton.new(select_matrix, "Contain sub directories", @is_subdirectory, FXDataTarget::ID_VALUE)
    FXFrame.new(select_matrix, LAYOUT_FILL_COLUMN|LAYOUT_FILL_ROW)
  end
  
  def get_progressbar
    @progressTarget = FXDataTarget.new(0)    
    FXProgressBar.new(@contents, @progressTarget, FXDataTarget::ID_VALUE, LAYOUT_SIDE_BOTTOM | LAYOUT_FILL_X | FRAME_SUNKEN | FRAME_THICK)
  end
  
  def get_result_table
    @table = FXTable.new(@contents, :opts => TABLE_COL_SIZABLE | TABLE_NO_COLSELECT | TABLE_ROW_RENUMBER | TABLE_READONLY | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    @table.visibleRows = 10
    @table.visibleColumns = 6
    @table.setTableSize(0, 7)
    @table.rowHeaderWidth = 50
    @table.setColumnText(0, "File")
    @table.setColumnWidth(0, 150)
    @table.setColumnText(1, "Directory")
    @table.setColumnWidth(1, 300)
    @table.setColumnText(2, "Total lines")
    @table.setColumnWidth(2, 80)
    @table.setColumnText(3, "Code lines")
    @table.setColumnWidth(3, 80)
    @table.setColumnText(4, "Comment lines")
    @table.setColumnWidth(4, 100)
    @table.setColumnText(5, "Blank lines")
    @table.setColumnWidth(5, 80)
    @table.setColumnText(6, "File type")
    @table.setColumnWidth(6, 80)
    
    @table.connect(SEL_COMMAND) do |sender, sel, tablePos|
      @table.selectRow(@table.currentRow, true)
    end
  end
  
  def insert_results(results)
    results[@results_index..-1].each do |result|
      rows = @table.numRows
      @table.appendRows(1)
      @table.setItemText(rows, 0, result.file_name)
      @table.setItemJustify(rows, 0, FXTableItem::LEFT)
      @table.setItemText(rows, 1, result.dir_name)
      @table.setItemJustify(rows, 1, FXTableItem::LEFT)
      @table.setItemText(rows, 2, result.total_lines.to_s)
      @table.setItemText(rows, 3, result.code_lines.to_s)
      @table.setItemText(rows, 4, result.comment_lines.to_s)
      @table.setItemText(rows, 5, result.blank_lines.to_s)
      @table.setItemText(rows, 6, result.file_type)
      @results_index += 1
    end
  end
  
  def refresh_results
    @total_files.value = @code_statistics.readable_total_files
    @total_sizes.value = @code_statistics.readable_total_size
    @total_lines.value = @code_statistics.readable_total_lines
    @code_lines.value = @code_statistics.readable_code_lines
    @comment_lines.value = @code_statistics.readable_comment_lines
    @blank_lines.value = @code_statistics.readable_blank_lines
    
    @code_line_percentage.value = @code_statistics.code_line_percentage
    @comment_line_percentage.value = @code_statistics.comment_line_percentage
    @blank_line_percentage.value = @code_statistics.blank_line_percentage
  end
  
  def get_result_groupbox
    result_groupbox = FXGroupBox.new(@contents, "Results", GROUPBOX_NORMAL | LAYOUT_FILL_X | FRAME_GROOVE)
    result_matrix = FXMatrix.new(result_groupbox, 6, MATRIX_BY_COLUMNS | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    FXLabel.new(result_matrix, "Total files: ")
    @total_files = FXDataTarget.new("")
    FXTextField.new(result_matrix, 10, @total_files, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Total sizes: ")
    @total_sizes = FXDataTarget.new("")
    FXTextField.new(result_matrix, 10, @total_sizes, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Total lines: ")
    @total_lines = FXDataTarget.new("")
    FXTextField.new(result_matrix, 10, @total_lines, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Code lines: ")
    @code_lines = FXDataTarget.new("")
    FXTextField.new(result_matrix, 10, @code_lines, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Comment lines: ")
    @comment_lines = FXDataTarget.new("")
    FXTextField.new(result_matrix, 10, @comment_lines, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Blank lines: ")
    @blank_lines = FXDataTarget.new("")
    FXTextField.new(result_matrix, 10, @blank_lines, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Code Line Percentage: ");
    @code_line_percentage = FXDataTarget.new("");
    FXTextField.new(result_matrix, 10, @code_line_percentage, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Comment Line Percentage: ");
    @comment_line_percentage = FXDataTarget.new("");
    FXTextField.new(result_matrix, 10, @comment_line_percentage, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    FXLabel.new(result_matrix, "Blank Line Percentage: ");
    @blank_line_percentage = FXDataTarget.new("");
    FXTextField.new(result_matrix, 10, @blank_line_percentage, FXDataTarget::ID_VALUE, TEXTFIELD_READONLY|TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    
  end
  
  #Create a toolbar, and initialize the menu items
  def get_tool_bar
    toolbar = FXToolBar.new(self, LAYOUT_SIDE_TOP | LAYOUT_FILL_X) #Create a toolbar
    statistic_btn = FXButton.new(toolbar, "Statistics", load_icon("statistics"), nil, 0, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT | ICON_ABOVE_TEXT)
    statistic_btn.connect(SEL_COMMAND, method(:on_cmd_statistics))
    save_btn = FXButton.new(toolbar, "Output", load_icon("save"), nil, 0, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT | ICON_ABOVE_TEXT)
    save_btn.connect(SEL_COMMAND, method(:on_cmd_save))
    setting_btn = FXButton.new(toolbar, "Setting", load_icon("setting"), nil, 0, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT | ICON_ABOVE_TEXT)
    setting_btn.connect(SEL_COMMAND, method(:on_cmd_setting))
    about_btn = FXButton.new(toolbar, "About", load_icon("about"), nil, 0, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT | ICON_ABOVE_TEXT)
    about_btn.connect(SEL_COMMAND, method(:on_cmd_about))
    FXButton.new(toolbar, "Exit", load_icon("exit"), getApp(), FXApp::ID_QUIT, FRAME_THICK | FRAME_RAISED | LAYOUT_TOP | LAYOUT_LEFT | ICON_ABOVE_TEXT)
  end
  
  def load_icon(filename)
    begin
      filename = File.join(File.dirname(__FILE__), '../..', 'image', filename) + '.png'
      icon = nil
      File.open(filename, "rb") do |f|
        icon = FXPNGIcon.new(getApp(), f.read)
      end
      icon
    rescue
      raise RuntimeError, "Couldn't load icon: #{filename}"
    end
  end
  
  def on_select_file(sender, sel, ptr)
    file_dlg = FXFileDialog.new(self, "Select a file")
    file_dlg.patternList = $parser
    unless file_dlg.execute == 0
      @file_name.value = File.basename(file_dlg.filename)
      @directory_name.value = File.dirname(file_dlg.filename)

      @file_types.each do |file_type|
        file_type.value = 0
      end
      @is_subdirectory.value = 0
    end
  end
  
  def on_select_directory(sender, sel, ptr)
    dir_dlg = FXDirDialog.new(self, "Select a directory")
    unless dir_dlg.execute == 0
      @file_name.value = ''
      @directory_name.value = dir_dlg.directory
    end
  end
  
  def file_types_empty?
    @file_types.each do |file_type|
      return false if file_type.value == 1
    end
    return true
  end
  
  def get_file_types
    index = 0
    file_types = []
    @file_types.each do |file_type|
      file_types << $parser[index] if file_type.value ==  1
      index += 1
    end
    file_types
  end
  
  def contain_subdirectory
    return true if @is_subdirectory.value == 1
    return false
  end
  
  def on_cmd_statistics(sender, sel, ptr)
    if (@file_name.value.empty? && file_types_empty?) || @directory_name.value.empty?
      FXMessageBox.warning(self, MBOX_OK, "Warning", "The file and direcotry should not be empty!")
    else
      @code_statistics = CodeStatistics.new
      @table.removeRows(0, @results_index)
      @results_index = 0
      getApp().addTimeout(TIMEOUT, method(:on_timeout))
      thread = Thread.new do
        if @file_name.value.empty?
          file_types = get_file_types
          @code_statistics.scan_direcotry(@directory_name.value, file_types, contain_subdirectory)
        else
          @code_statistics.scan_file(@directory_name.value =~ Regexp.new("#{File::SEPARATOR}$") ? @directory_name.value + @file_name.value : @directory_name.value + File::SEPARATOR + @file_name.value)
        end
      end
      thread.run
    end
  end
  
  def on_cmd_save(sender, sel, ptr)
    if @code_statistics
      file_dlg = FXFileDialog.new(self, "Save to a html file")
      if PLATFORM == 'i386-mswin32'
        file_dlg.patternList = ["*.html", "*.xls"]
      else
        file_dlg.patternList = ["*.html"]
      end
      unless file_dlg.execute == 0
        filename = File.fnmatch(file_dlg.pattern, file_dlg.filename) ? file_dlg.filename : file_dlg.filename + file_dlg.pattern[1..-1]
        case File.extname(filename)
        when '.html' then Output.to_html(filename, @code_statistics)
        when '.xls' then Output.to_excel(filename, @code_statistics)
        end
      end
    else
      FXMessageBox.warning(self, MBOX_OK, "Warning", "You should statistics first!")
    end
  end
  
  def on_cmd_setting(sender, sel, ptr)
    if SettingDialog.new(self).execute == 1
#      @file_types_matrix.each_child do |check_button|
#        check_button.destroy
#      end
#      @file_types = []
#      $parser.each do |file_type|
#        dt = FXDataTarget.new(0)
#        @file_types << dt
#        FXCheckButton.new(@file_types_matrix, file_type, dt, FXDataTarget::ID_VALUE)
#      end
    end
  end
  
  def on_cmd_about(sender, sel, ptr)
    AboutDialog.new(self).execute
  end
  
  def on_ext(send, sel, ptr)
    handle(self, FXSEL(SEL_COMMAND, FXApp::ID_QUIT), nil)
  end
  
  # Timer expired; update the progress
  def on_timeout(sender, sel, ptr)
    if @code_statistics.is_scanning
      # Increment the progress modulo 100
      @progressTarget.value = (@progressTarget.value + 10) % 100
      insert_results(@code_statistics.results)
      refresh_results
      # Reset the timer for next time
      getApp().addTimeout(TIMEOUT, method(:on_timeout))
    else
      @progressTarget.value = 0 
      insert_results(@code_statistics.results)
      refresh_results
    end
  end
  
  def create
    super
    show(PLACEMENT_SCREEN)
  end
end
