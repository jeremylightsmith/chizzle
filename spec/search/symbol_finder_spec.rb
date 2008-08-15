require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'search/match'
require 'search/symbol_finder'

describe SymbolFinder, " with 3 results" do
  before do
    @strategy = Object.new
    @finder = SymbolFinder.alloc.initWithStrategy(@strategy)
    
    @finder.window = FakeUI::Window.new
    @finder.window.makeKeyWindow
    
    @finder.search_field = FakeUI::TextField.new
    
    @finder.matches_table = @table = FakeUI::TableView.new
    @table.setDataSource(@finder)
    
    @strategy.stubs(:find_matches).returns(%w(one two three).map{|n|Match.new(n, "#{n}.rb", 20)})
  end
  
  it "should be datasource for table" do
    @finder.search(nil)
    
    @finder.numberOfRowsInTableView(nil).should == 3
    @finder.tableView_objectValueForTableColumn_row(nil, nil, 0).should == "one"
    @finder.tableView_objectValueForTableColumn_row(nil, nil, 1).should == "two"
    @finder.tableView_objectValueForTableColumn_row(nil, nil, 2).should == "three"
    @table.selectedRow.should == 0
  end
  
  it "should pass the right thing into find_matches" do
    @strategy.expects(:find_matches).with('hello')
    @finder.search_field.setStringValue "hello"

    @finder.search(nil)
  end
  
  it "should change the selection when user presses up / down" do
    @finder.search(nil)

    @finder.control_textView_doCommandBySelector(nil, nil, "moveDown:")
    @table.selectedRow.should == 1

    @finder.control_textView_doCommandBySelector(nil, nil, "moveUp:")
    @table.selectedRow.should == 0

    @finder.control_textView_doCommandBySelector(nil, nil, "moveUp:")
    @table.selectedRow.should == 0

    10.times { @finder.control_textView_doCommandBySelector(nil, nil, "moveDown:") }
    @table.selectedRow.should == 2
  end

  it "should call a block on accept" do
    result = ""
    @finder.on_accept {|file, line| result << "#{file} - #{line}"}
    
    @finder.window.isKeyWindow.should == true

    @finder.search(nil)
    @table.selectRow_byExtendingSelection(2, false)
    @finder.accept
    
    result.should == "three.rb - 20"
    @finder.window.isKeyWindow.should == false
  end
end

