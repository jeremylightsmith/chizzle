require 'editor'
require 'script_runner'

class AppController < OSX::NSObject
  include OSX
  ib_outlet :drawer, :file_list, :file_tabs, :output_view, :window
  
  attr_accessor :editors
  
  def init
    @editors = []
    self
  end
  
  def awakeFromNib
    # bring to front when launched from command line
    NSApplication.sharedApplication.activateIgnoringOtherApps(true)  
    
    @drawer.toggle(self)
    @file_tabs.removeTabViewItem(@file_tabs.tabViewItemAtIndex(0))
  end
  
  def applicationDidFinishLaunching(notification)
    @runner = ScriptRunner.new(@output_view)
    
    NSNotificationCenter.defaultCenter.addObserver_selector_name_object self, 'refresh:', NSWindowDidBecomeMainNotification, @window
    NSNotificationCenter.defaultCenter.addObserver_selector_name_object self, 'save_all:', NSWindowDidResignMainNotification, @window
  end
  
  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver(self)
    super_dealloc
  end
  
  def applicationShouldTerminate(app)
    # NSTerminateLater
    NSTerminateNow
  end
  
  def application_openFiles(sender, file_names)
    if file_names.size == 1
      @project = Project.new(file_names[0].to_s)
      @file_list.project = @project
      @window.makeFirstResponder(@file_list.view)
    elsif file_names.size > 1
      raise "can only handle one file / directory currently" 
    end
  end
  
  def applicationWillTerminate(notification)
  end
  
  def selected_editor
    tab = @file_tabs.selectedTabViewItem
    tab ? tab.identifier : nil
  end
  
  def refresh(sender = nil)
    @file_list.refresh
  end
  
  def save_all(sender = nil)
    @editors.each {|e| e.save }
  end
  
  def run
    editor = selected_editor
    if editor
      save_all
      @runner.run_file(editor.path)
    else
      alert('no editor was selected')
    end
  end
  
  def close_file
    tab = @file_tabs.selectedTabViewItem
    return unless tab
    
    editor = tab.identifier
    editor.save
    
    @file_tabs.removeTabViewItem(tab)
    editors.delete editor
  end
  
  def open_file(file_name)
    file_name = File.expand_path(file_name)
    
    if editor = editors.find {|editor| editor.path == file_name }
      @file_tabs.selectTabViewItem editor.tab_view_item
      return
    end
    
    fonts = NSFontManager.sharedFontManager

    text_view = NSTextView.alloc.initWithFrame(@file_tabs.contentRect)
    text_view.setFont fonts.fontWithFamily_traits_weight_size("Courier", 0, 5, 12)

    scroll_view = NSScrollView.alloc.initWithFrame(@file_tabs.contentRect)
    scroll_view.setHasVerticalScroller true
    scroll_view.setHasHorizontalScroller false
    scroll_view.setDocumentView text_view
    
    tab = NSTabViewItem.alloc.init
    tab.setView scroll_view

    editor = Editor.new(file_name, text_view, tab)
    editors << editor
    tab.setIdentifier editor
    tab.setLabel editor.name

    puts "setting text view selected range"
    puts "text view is #{text_view}"
    raise "boo"
    text_view.setSelectedRange [0,0].to_range
    text_view.scrollRangeToVisible [0,0].to_range
    
    @file_tabs.addTabViewItem tab
    @file_tabs.selectTabViewItem tab
    
    @window.makeFirstResponder(text_view)
  end

  def goto_file
    open_finder(FileFinderStrategy.new(@project))
  end
  
  def goto_symbol
    alert 'not yet implemented'
  end
  
  def goto_class
    alert 'not yet implemented'
  end
  
  def focus_to_editor
    editor = selected_editor
    @window.makeFirstResponder(editor.text_view) if editor
  end
  
  def focus_to_file_list
    @window.makeFirstResponder(@file_list.view)
  end
  
  def focus_to_output
    @window.makeFirstResponder(@output_view)    
  end
  
  def selected_directory
    @file_list.selected_directory
  end
  
  private
  
  def open_finder(strategy)
    if !@finder
      @finder = SymbolFinder.alloc.initWithStrategy(strategy)
      @finder.on_accept do |file, line| 
        begin
          open_file(file) 
        rescue Exception
          alert "Error opening #{file} : #{$!}"
        end
      end
        
      NSBundle.loadNibNamed_owner("SymbolFinderPanel", @finder)
    else
      @finder.strategy = strategy
    end

    @finder.show(self)
  end
end
