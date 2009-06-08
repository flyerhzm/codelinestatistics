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

# This is an about dialog.
class AboutDialog < FXDialogBox
  
  def initialize(parent)
    super(parent, "About", DECOR_TITLE | DECOR_BORDER)    
    get_buttons
    get_separator
    get_contents
  end
  
  def get_contents
    contents = FXVerticalFrame.new(self, LAYOUT_SIDE_TOP | FRAME_NONE | LAYOUT_FILL_X | LAYOUT_FILL_Y | PACK_UNIFORM_WIDTH)
    FXLabel.new(contents, "Version: 1.0", nil, LAYOUT_SIDE_TOP | JUSTIFY_LEFT)
    FXLabel.new(contents, "Author: flyerhzm <flyerhzm@gmail.com>", nil, LAYOUT_SIDE_TOP | JUSTIFY_LEFT)
  end
  
  def get_separator
    FXHorizontalSeparator.new(self,	LAYOUT_SIDE_BOTTOM | LAYOUT_FILL_X | SEPARATOR_GROOVE)  	
  end
  
  def get_buttons
    buttons = FXHorizontalFrame.new(self,	LAYOUT_SIDE_BOTTOM | FRAME_NONE | LAYOUT_FILL_X | PACK_UNIFORM_WIDTH)  	
    ok_button = FXButton.new(buttons, "OK", nil, self, ID_ACCEPT,  FRAME_RAISED | FRAME_THICK | LAYOUT_CENTER_X | LAYOUT_CENTER_Y)
    ok_button.setDefault
    ok_button.setFocus
  end
end
