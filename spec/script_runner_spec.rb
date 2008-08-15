require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'script_runner'

describe ScriptRunner, " with a file to run" do
  include FileSandbox
  
  before do
    @output = FakeUI::TextView.new
    @runner = ScriptRunner.new(@output)
  end
  
  it "should write to stdout" do
    sandbox.new :file => 'hello_world.rb', :with_contents => "puts 'hello world!'"
    @runner.run_file_synchronously sandbox.root + "/hello_world.rb"
    
    @output.string.should == <<-EOL
> ruby hello_world.rb
hello world!
    EOL
  end
  
  it "should clear the buffer between runs" do
    sandbox.new :file => 'hello_world.rb', :with_contents => "puts 'hello world!'"

    @runner.run_file_synchronously sandbox.root + "/hello_world.rb"
    @runner.run_file_synchronously sandbox.root + "/hello_world.rb"

    @output.string.should == <<-EOL
> ruby hello_world.rb
hello world!
    EOL
  end
  
  it "should redirect stderr as well" do
    sandbox.new :file => 'error.rb', :with_contents => <<-EOL
      $stderr.puts 'ouch'
      $stdout.puts 'who'
      $stderr.puts 'hit'
      $stdout.puts 'me'
    EOL

    @runner.run_file_synchronously sandbox.root + "/error.rb"

    @output.string.split("\n").sort.join(" ").should == "> ruby error.rb hit me ouch who"
  end
end
