require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'new_file_controller'

describe "a new file controller", :shared => true do
  before do
    @controller = NewFileController.alloc.init
    @controller.app_controller = @app_controller = Object.new
    @controller.name_field = @name = FakeUI::TextField.new
    @controller.location_field = @loc = FakeUI::TextField.new
    @controller.window = @window = FakeUI::Window.new
  end
end

describe NewFileController do
  it_should_behave_like 'a new file controller'
  it_should_behave_like 'a dialog controller'
  
  before do
    @app_controller.stubs(:selected_directory).returns("my_app/lib")
  end
  
  it "should get it's default location from selected dir in file_list on show" do
    @controller.show
    @loc.stringValue.should == File.expand_path("my_app/lib")
  end
end

describe NewFileController, ' creating files' do
  include FileSandbox
  it_should_behave_like 'a new file controller'

  before do
    @app_controller.stubs(:selected_directory).returns(@sandbox.root)
    @controller.show
  end
    
  it "should create and open a new file on create" do
    @app_controller.expects(:open_file).with(File.expand_path(@sandbox.root + "/my_file.rb"))
    @app_controller.expects(:refresh)
    @name.setStringValue "my_file.rb"
    
    @controller.create
    
    sandbox["my_file.rb"].should exist
    @window.isKeyWindow.should == false
  end
  
  it "should barf if the directory doesn't exist" do
    @loc.setStringValue 'made_up_dir/foo'
    
    lambda { @controller.create }.should raise_error
    
    @window.isKeyWindow.should == true
  end
  
  it "should barf if the file already exists" do
    sandbox.new :file => 'foo.rb'
    
    @name.setStringValue 'foo.rb'

    lambda { @controller.create }.should raise_error
    
    @window.isKeyWindow.should == true
  end
end
