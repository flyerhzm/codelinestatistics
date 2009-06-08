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

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'statistics', 'configure'))

# SettingDialog is for configuration.
class SettingDialog < FXDialogBox
  
  def initialize(parent)
    super(parent, "Setting", DECOR_TITLE | DECOR_BORDER)
    
    get_buttons
    get_contents
    
    @file_mapping = Configure.get_hash(Configure::FILE_MAPPING)
    @file_mapping.each do |key, value|
      insert_row(key, value)
    end
  end
  
  def get_contents
    @contents = FXVerticalFrame.new(self, LAYOUT_SIDE_TOP | FRAME_NONE | LAYOUT_FILL_X | LAYOUT_FILL_Y | PACK_UNIFORM_WIDTH)
    get_tabbook
  end
  
  def get_tabbook
    @tabbook = FXTabBook.new(@contents, :opts => LAYOUT_FILL_X | LAYOUT_FILL_Y | LAYOUT_RIGHT)
    get_param_tab
    get_file_mapping_tab
  end
  
  def get_param_tab
    @param_tab = FXTabItem.new(@tabbook, "Parameter Setting", nil)
    @param_frame = FXVerticalFrame.new(@tabbook, FRAME_THICK | FRAME_RAISED)
    get_trailing_comment_group    
    get_annotation_comment_group 
  end
  
  def get_file_mapping_tab
    @file_mapping_tab = FXTabItem.new(@tabbook, "File Mapping Setting", nil)
    @file_mapping_frame = FXVerticalFrame.new(@tabbook, FRAME_THICK | FRAME_RAISED)
    get_warning_label
    get_file_mapping_group
    get_exits_file_mapping_group
  end
  
  def get_warning_label
    warning = FXLabel.new(@file_mapping_frame, "Change will be effected after restarting the application!")
    warning.textColor = FXRGB(255, 0, 0)
  end
  
  def get_trailing_comment_group
    @trailing_comment_dt = FXDataTarget.new(0)
    gp = FXGroupBox.new(@param_frame, "Trailing comment: ", GROUPBOX_TITLE_LEFT | FRAME_RIDGE | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    index = 0
    Configure::TRAILING_COMMENT_VALUE.keys.each do |value|
      FXRadioButton.new(gp, value, @trailing_comment_dt, FXDataTarget::ID_OPTION + index, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
      index += 1
    end
    @trailing_comment_dt.value = Configure.get_value(Configure::TRAILING_COMMENT)
  end
  
  def get_annotation_comment_group
    @annotation_comment_dt = FXDataTarget.new(0)
    gp = FXGroupBox.new(@param_frame, "Java Annotation: ", GROUPBOX_TITLE_LEFT | FRAME_RIDGE | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    index = 0
    Configure::JAVA_ANNOTATION_VALUE.keys.each do |value|
      FXRadioButton.new(gp, value, @annotation_comment_dt, FXDataTarget::ID_OPTION + index, ICON_BEFORE_TEXT|LAYOUT_SIDE_TOP)
      index += 1
    end
    @annotation_comment_dt.value = Configure.get_value(Configure::JAVA_ANNOTATION)
  end
  
  def get_file_mapping_group
    gp = FXGroupBox.new(@file_mapping_frame, "File Mapping: ", GROUPBOX_NORMAL | LAYOUT_FILL_X | FRAME_GROOVE)
    file_matrix = FXMatrix.new(gp, 6, MATRIX_BY_COLUMNS | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    FXLabel.new(file_matrix, "File extension: ")
    @file_extension = FXDataTarget.new("")
    FXTextField.new(file_matrix, 10, @file_extension, FXDataTarget::ID_VALUE, TEXTFIELD_NORMAL|LAYOUT_FILL_X|LAYOUT_FILL_COLUMN)
    
    FXLabel.new(file_matrix, "Mapping to: ")
    @parser_combo = FXComboBox.new(file_matrix, 10, nil, 0, :opts => COMBOBOX_NORMAL | COMBOBOX_STATIC | LAYOUT_FIX_WIDTH, :width => 100)
    @parser_combo.appendItem("")
    $parser.each do |parser|
      @parser_combo.appendItem(parser.split(".")[1])
    end
    
    insert_btn = FXButton.new(file_matrix, "&Insert", nil, self, 0, FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
    insert_btn.connect(SEL_COMMAND, method(:on_insert))
  end 
  
  def get_exits_file_mapping_group
    gp = FXGroupBox.new(@file_mapping_frame, "Exist", GROUPBOX_NORMAL | LAYOUT_FILL_X | FRAME_GROOVE)
    mapping_matrix = FXVerticalFrame.new(gp, LAYOUT_SIDE_TOP | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    @table = FXTable.new(mapping_matrix, :opts => TABLE_COL_SIZABLE | TABLE_NO_COLSELECT | TABLE_ROW_RENUMBER | TABLE_READONLY | LAYOUT_FILL_X | LAYOUT_FILL_Y)
    @table.visibleRows = 5
    @table.visibleColumns = 1
    @table.setTableSize(0, 2)
    @table.rowHeaderWidth = 50
    @table.setColumnText(0, "File extension")
    @table.setColumnWidth(0, 210)
    @table.setColumnText(1, "Mapping to")
    @table.setColumnWidth(1, 210)
    @table.rowHeaderWidth = 0
    
    @table.connect(SEL_COMMAND) do |sender, sel, tablePos|
      @table.selectRow(@table.currentRow, true)
    end
    
    delete_btn = FXButton.new(mapping_matrix, "&Delete", nil, self, 0, FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
    delete_btn.connect(SEL_COMMAND, method(:on_delete))
  end
  
  def get_buttons
    buttons = FXHorizontalFrame.new(self,	LAYOUT_SIDE_BOTTOM | FRAME_NONE | LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)  	
    accept_btn = FXButton.new(buttons, "&Accept", nil, self, 0, FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
    accept_btn.connect(SEL_COMMAND, method(:on_ok))
    FXButton.new(buttons, "&Cancel", nil, self, ID_CANCEL, FRAME_RAISED|FRAME_THICK|LAYOUT_RIGHT|LAYOUT_CENTER_Y)
    
    accept_btn.setDefault  
    accept_btn.setFocus
  end
  
  def on_ok(sender, sel, ptr)
    Configure.set_value(Configure::TRAILING_COMMENT, @trailing_comment_dt.value)
    Configure.set_value(Configure::JAVA_ANNOTATION, @annotation_comment_dt.value)
    Configure.set_hash(Configure::FILE_MAPPING, @file_mapping)
    Configure.dump
    handle(self, FXSEL(SEL_COMMAND, FXDialogBox::ID_ACCEPT), nil)
  end
  
  def on_insert(send, sel, ptr)
    size = @file_mapping.size
    @file_mapping[@file_extension.value] = @parser_combo.getItemText(@parser_combo.currentItem)
    if @file_mapping.size > size
      insert_row(@file_extension.value, @parser_combo.getItemText(@parser_combo.currentItem))
    end
  end
  
  def on_delete(send, sel, ptr)
    if @table.currentRow >= 0
      file_extension = @table.getItemText(@table.currentRow, 0)
      @file_mapping.delete(file_extension)
      @table.removeRows(@table.currentRow)
    end
  end
  
  def insert_row(file_extension, parser)
    rows = @table.numRows
    @table.appendRows(1)
    @table.setItemText(rows, 0, file_extension)
    @table.setItemJustify(rows, 0, FXTableItem::LEFT)
    @table.setItemText(rows, 1, parser)
    @table.setItemJustify(rows, 1, FXTableItem::LEFT)
  end
end