require 'osx/cocoa'

module Kernel
  def alert(message, options = {})
    OSX::NSRunAlertPanel(options.delete(:title) || "Alert", 
                         message,
                         options.delete(:default_button) || "OK", 
                         options.delete(:alternate_button), 
                         options.delete(:other_button))
                         
    alert("unknown params : #{options.inspect}") unless options.empty?
  end
end

class Array
  def to_range
    raise unless size == 2
    OSX::NSRange.new(*self)
  end
end
