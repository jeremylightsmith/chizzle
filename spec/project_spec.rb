require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'project'

describe Project do
  include FileSandbox
  
  before do
    @project = Project.new(sandbox.root)
  end

  it "should make project relative" do
    @project.make_project_relative(sandbox.root + "/foobar.rb").should == "foobar.rb"
  end
end

