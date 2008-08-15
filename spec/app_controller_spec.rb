require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'app_controller'

class AppController
  NSTextView = FakeUI::TextView
end

describe AppController, ' with 2 files' do
  include FileSandbox
  
  before do
    @sandbox.new :file => 'Rakefile', :with_contents => "require 'rake'"
    @sandbox.new :file => 'lib/alert.rb', :with_contents => "class Alert\nend"

    @alert_path = @sandbox.root + "/lib/alert.rb"
    @rakefile_path = @sandbox.root + "/Rakefile"
    
    @app_controller = AppController.alloc.init
    @app_controller.window = FakeUI::Window.new
    @app_controller.file_tabs = @tabs = FakeUI::TabView.new
  end
  
  it "should open a tab" do
    @app_controller.open_file(@alert_path)
    
    @app_controller.editors.size.should == 1
    
    editor = @app_controller.editors[0]
    editor.path.should == @alert_path

    @tabs.tabViewItems.should == [editor.tab_view_item]
    @tabs.selectedTabViewItem.should == editor.tab_view_item
    editor.text_view.string.to_s.should == "class Alert\nend"
  end
  
  it ' should switch focus when opening a tab' do
    @app_controller.open_file(@alert_path)
    @app_controller.open_file(@rakefile_path)
    
    @app_controller.editors.size.should == 2
    
    editor = @app_controller.editors[1]
    editor.path.should == @rakefile_path

    @tabs.selectedTabViewItem.should == editor.tab_view_item
    editor.text_view.string.to_s.should == "require 'rake'"
  end
  
  it 'should only switch focus when reopening a tab' do
    @app_controller.open_file(@alert_path)
    @app_controller.open_file(@rakefile_path)
    @app_controller.open_file(@alert_path)
    
    @app_controller.editors.size.should == 2
    
    editor = @app_controller.editors[0]
    editor.path.should == @alert_path

    @tabs.selectedTabViewItem.should == editor.tab_view_item
  end
end

describe AppController, 'with 2 open files' do
  include FileSandbox
  
  before do
    @sandbox.new :file => 'Rakefile', :with_contents => "require 'rake'"
    @sandbox.new :file => 'lib/alert.rb', :with_contents => "class Alert\nend"

    @alert_path = @sandbox.root + "/lib/alert.rb"
    @rakefile_path = @sandbox.root + "/Rakefile"
    @runner = Object.new
    
    @app_controller = AppController.alloc.init
    @app_controller.instance_variable_set("@runner", @runner)
    @app_controller.window = FakeUI::Window.new
    @app_controller.file_tabs = @tabs = FakeUI::TabView.new
    
    @app_controller.open_file(@alert_path)
    @app_controller.open_file(@rakefile_path)
  end

  it "should save all and use the current editor on run" do
    @runner.expects(:run_file).with(@rakefile_path)
    @app_controller.expects(:save_all)
    
    @app_controller.run
  end
  
  it "should save all" do
    @app_controller.editors[0].expects(:save)
    @app_controller.editors[1].expects(:save)
    
    @app_controller.save_all
  end
  
  it "should close tabs" do
    @app_controller.close_file
    @tabs.tabViewItems.size.should == 1
    @tabs.tabViewItems[0].identifier.name.should == 'alert.rb'

    @app_controller.close_file
    @tabs.tabViewItems.size.should == 0
    @app_controller.close_file
  end
  
  it "should save a file before closing" do
    @app_controller.editors[1].text_view.setString "new content"

    File.read(@rakefile_path).should_not == "new content"

    @app_controller.close_file
    
    File.read(@rakefile_path).should == "new content"
  end
  
end
