require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'tab_controller'

describe TabController, ' with 3 tabs' do
  before do
    @controller = TabController.alloc.init
    @controller.tab_view = @tabs = FakeUI::TabView.new
    
    @tabs.addTabViewItem 1
    @tabs.addTabViewItem 2
    @tabs.addTabViewItem 3
    
    @tabs.selectTabViewItem 1
  end
  
  it "should go to next tab and loop back" do
    @controller.next_tab
    @tabs.selectedTabViewItem.should == 2
    
    @controller.next_tab
    @tabs.selectedTabViewItem.should == 3
    
    @controller.next_tab
    @tabs.selectedTabViewItem.should == 1
  end

  it "should go to next tab and loop back" do
    @controller.previous_tab
    @tabs.selectedTabViewItem.should == 3
    
    @controller.previous_tab
    @tabs.selectedTabViewItem.should == 2
    
    @controller.previous_tab
    @tabs.selectedTabViewItem.should == 1
  end
end

describe TabController, ' with 0 tabs' do
  before do
    @controller = TabController.alloc.init
    @controller.tab_view = @tabs = FakeUI::TabView.new
  end
  
  it "should not have any errors when going to the next and previous tabs" do
    @controller.next_tab
    @controller.previous_tab
  end
end


