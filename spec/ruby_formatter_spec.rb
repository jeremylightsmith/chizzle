require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ruby_formatter'

describe RubyFormatter do
  before do
    @formatter = RubyFormatter.new
  end
  
  it "should color keywords" do
    # colorize(%{
    #   require a really long
    #   do end begin rescue
    # }).should == %{
    #   <keyword></keyword>
    # }
  end
end
