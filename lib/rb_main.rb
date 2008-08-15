require File.dirname(__FILE__) + "/../config/environment"
require 'fileutils'

module Kernel
  def puts(*args)
    $stderr.puts(*args)
  end
end

def rb_main_init
  ruby_files.each do |f| 
    require f
  end
end

def ruby_files
  path = OSX::NSBundle.mainBundle.resourcePath.fileSystemRepresentation
  FileUtils.chdir path do
    return Dir["lib/**/*.rb"]
  end
end

if $0 == __FILE__ then
  rb_main_init
  OSX.NSApplicationMain(0, nil)
end
