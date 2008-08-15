require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'goto_line_controller'

describe GotoLineController do
  it_should_behave_like 'a dialog controller'

  before do
    @controller = GotoLineController.alloc.init
    @controller.app_controller = @app_controller = mock('app controller')
    @controller.line_field = @line = FakeUI::TextField.new
    @controller.window = @window = FakeUI::Window.new
    @app_controller.stubs(:selected_editor).returns(@editor = mock('editor'))
  end
  
  it "shouldn't show unless there is an editor" do
    @app_controller.stubs(:selected_editor).returns(nil)
    
    @controller.show
    
    should be_closed
  end
    
  it "should move cursor to line on go" do
    @controller.show

    @editor.expects(:goto_line).with(5)
    @line.setStringValue "5"
    
    @controller.go
    
    closed?.should be_true
  end
  
  it "should alert if line is not a number" do
    @controller.show

    @line.setStringValue 'licorice'
    @controller.expects(:alert).with("line should be a number")
    
    @controller.go
    
    closed?.should == false
  end
end
