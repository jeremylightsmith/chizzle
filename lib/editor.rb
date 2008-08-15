require 'languages/arithmetic_language'
require 'languages/text_language'

class Editor
  attr_accessor :path, :text_view, :tab_view_item, :language
  
  def initialize(path, text_view, tab_view_item)
    @path, @text_view, @tab_view_item = path, text_view, tab_view_item
    
    @language = @path =~ /\.math$/ ? ArithmeticLanguage.new(text_view) : TextLanguage.new
    @text_view.setDelegate(@language)
    
    # @text_view.insertText(File.read(path))
  end
  
  def name
    File.basename(@path)
  end
  
  def save
    File.open(@path, "w+") {|f| f.write @text_view.string }
  end
  
  def contents
    @text_view.string
  end
  
  def goto_line(line)
    offset = 0
    contents = @text_view.string.to_s

    while (line -= 1) >= 1
      index = contents.index("\n", offset)
      break if index.nil? || contents.size == index
      
      offset = index + 1
    end
    
    @text_view.setSelectedRange     [offset, 0].to_range
    @text_view.scrollRangeToVisible [offset, 0].to_range
  end
end