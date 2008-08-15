require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'file_list/file_list_controller'
require 'project'

describe FileListController, ' with a simple hierarchy' do
  include FileSandbox
  
  before do
    @sandbox.new :file => 'app/Rakefile'
    @sandbox.new :file => 'app/lib/alert.rb'
    @sandbox.new :file => 'app/lib/app_controller.rb'
    @sandbox.new :file => 'app/lib/commands/save.rb'
    @sandbox.new :file => 'app/test/test_helper.rb'
    
    @controller = FileListController.alloc.init
    @controller.view = FakeUI::OutlineView.new
    @controller.view.setDataSource(@controller)
    @controller.project = Project.new(@sandbox.root + "/app")

    @root = @controller.outlineView_child_ofItem(view, 0, nil)
    @rakefile = @controller.outlineView_child_ofItem(view, 1, @root)
    @lib = @controller.outlineView_child_ofItem(view, 0, @root)
    @alert = @controller.outlineView_child_ofItem(view, 0, @lib)
  end
  
  it "should load all children in the right places" do
    @controller.view.to_s.should == <<-EOL
app
  lib
    alert.rb
    app_controller.rb
    commands
      save.rb
  Rakefile
  test
    test_helper.rb
    EOL
  end

  it "should handle adding children and removing children" do
    @controller.view.to_s # load everything
    
    @sandbox.new :file => 'app/bin/help.rb'
    @sandbox.new :file => 'app/rake.rb'
    @sandbox.new :file => 'app/lib/commands/cheer'
    FileUtils.rm_rf(@sandbox.root + "/app/test")
    FileUtils.rm_rf(@sandbox.root + "/app/lib/app_controller.rb")
    FileUtils.rm_rf(@sandbox.root + "/app/Rakefile")
    @controller.refresh
    @controller.view.to_s.should == <<-EOL
app
  bin
    help.rb
  lib
    alert.rb
    commands
      cheer
      save.rb
  rake.rb
    EOL
  end
  
  it 'has one root' do
    @controller.outlineView_numberOfChildrenOfItem(view, nil).should == 1
    @controller.outlineView_isItemExpandable(view, nil).should == true
    
    @controller.outlineView_child_ofItem(view, 0, nil).name.should == 'app'
  end
  
  it 'has 3 children' do
    @controller.outlineView_numberOfChildrenOfItem(view, @root).should == 3
    @controller.outlineView_isItemExpandable(view, @root).should == true
    
    lib, rakefile, test = [0,1,2].map{|i| @controller.outlineView_child_ofItem(view, i, @root)}
    
    lib.name.should == "lib"
    test.name.should == "test"
    rakefile.name.should == "Rakefile"

    @controller.outlineView_objectValueForTableColumn_byItem(view, nil, lib).should == "lib"
    @controller.outlineView_objectValueForTableColumn_byItem(view, nil, test).should == "test"
    @controller.outlineView_objectValueForTableColumn_byItem(view, nil, rakefile).should == "Rakefile"
  end
  
  it 'can rename files' do
    @controller.outlineView_setObjectValue_forTableColumn_byItem(view, "crap", nil, @rakefile)
    
    @rakefile.name == 'crap'
    sandbox['app/crap'].exist?.should == true
    sandbox['app/Rakefile'].exist?.should == false
  end
  
  it "shouldn't overwrite files when renaming" do
    @controller.outlineView_setObjectValue_forTableColumn_byItem(view, "lib", nil, @rakefile)
    
    @rakefile.name == 'Rakefile'
    sandbox['app/Rakefile'].exist?.should == true
  end

  it "should default selected directory to project dir" do
    @controller.expects(:selected_item).returns(nil)
    @controller.selected_directory.should == @root.path
  end
  
  it "should show directory if selected" do
    @controller.expects(:selected_item).returns(@lib)
    @controller.selected_directory.should == @lib.path
  end
  
  it "should show parent directory if file is selected" do
    @controller.expects(:selected_item).returns(@alert)
    @controller.selected_directory.should == @lib.path
  end
  
  private 
  def view
    nil
  end
end
