require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'editor'

describe Editor do
  include FileSandbox
  
  before do
    @sandbox.new :file => 'Rakefile', :with_contents => "require 'rake'"

    @path = @sandbox.root + "/Rakefile"

    @text_view = FakeUI::TextView.new
    @editor = Editor.new(@path, @text_view, nil)
  end

  it 'should load an editor' do
    @text_view.string.should == "require 'rake'"
  end
  
  it 'should save an editor' do
    @text_view.insertText("\ntask [:default]")
    
    @editor.save
    
    File.read(@path).should == "require 'rake'\ntask [:default]"
  end

  it 'should expose its files contents' do
    @editor.contents.should == "require 'rake'"
  end
  
  it 'should goto line (1 based)' do
    @text_view.setString <<-EOL
line 1
line 2
line 3
line 4
line 5
    EOL
    
    @editor.goto_line(1)
    @text_view.selectedRange.should == [0, 0]
    
    @editor.goto_line(2)
    @text_view.selectedRange.should == [7, 0]
    
    @editor.goto_line(5)
    @text_view.selectedRange.should == [28, 0]
    
    @editor.goto_line(28)
    @text_view.selectedRange.should == [35, 0]
    
    @text_view.setString "two\nlines"
    
    @editor.goto_line(28)
    @text_view.selectedRange.should == [4, 0]
  end
end

