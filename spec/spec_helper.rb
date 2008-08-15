ENV["CHIZZLE_ENV"] = 'test'
require File.dirname(__FILE__) + "/../config/environment"

gem "rspec", ">= 1.1.4"
gem "mocha", ">= 0.5.6"
gem "file_sandbox", ">= 0.3"
gem "jeremylightsmith-fakeui", ">= 0.2"

require "spec"
require 'file_sandbox_behavior'
require 'fakeui'

$LOAD_PATH.unshift "#{CHIZZLE_ROOT}/spec"

module Kernel
  def retries(times, &block)
    yield
  rescue Exception
    raise unless times > 0
    sleep 0.2
    retries(times - 1, &block)
  end
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
end

describe 'a dialog controller', :shared => true do
  module Helper
    def closed?
      !@window.isKeyWindow
    end
  end  
  include Helper
  
  it "should show itself on show" do
    @controller.show
    closed?.should == false
  end
  
  it "should hide itself on cancel" do
    @controller.show
    @controller.cancel
    closed?.should == true
  end
end
