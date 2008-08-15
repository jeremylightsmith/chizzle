require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'project'
require 'search/file_finder_strategy'

describe FileFinderStrategy do
  include FileSandbox
  
  before do
    sandbox.new :file => 'apples'
    sandbox.new :file => 'lib/banana.rb'
    sandbox.new :file => 'lib/banana bread.rb'
    sandbox.new :file => 'apple/cake.html'
    sandbox.new :file => 'README'

    @strategy = FileFinderStrategy.new(Project.new(sandbox.root))
  end
  
  it "should find files" do
    names(@strategy.find_matches("apple")).should == ['apples']
    names(@strategy.find_matches("banana")).should == ['banana bread.rb', 'banana.rb']
    names(@strategy.find_matches("read")).should == ['README', 'banana bread.rb']
  end
  
  private 
  
  def names(matches)
    matches.sort.map {|m| m.display_name }
  end
end

