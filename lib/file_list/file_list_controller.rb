require 'fileutils'

class FileListController < OSX::NSObject
  attr_accessor :view
  attr_writer :app_controller
  
  def initialize
    @roots = Roots.new
  end

  def awakeFromNib
    @view.setDoubleAction :open_selected_file
    @view.setTarget self
  end
  
  def outlineView_shouldEditTableColumn_item(view, column, item)
    item.directory?
  end

  def selected_directory
    item = selected_item
    if !item
      @roots.children[0].path
    elsif item.directory?
      item.path
    else
      File.dirname(item.path)
    end    
  end
  
  def project=(project)
    item = FileItem.alloc.init_with_path(File.expand_path(project.root))
    @roots.children = [item]
    @view.reloadData
    @view.expandItem(item)
  end
  
  def outlineView_numberOfChildrenOfItem(view, item)
    file_item(item).children.size
  end

  def outlineView_isItemExpandable(view, item)
    file_item(item).directory?
  end

  def outlineView_child_ofItem(view, index, item)
    file_item(item).children[index]
  end

  def outlineView_objectValueForTableColumn_byItem(view, column, item)
    item.name
  end
  
  def outlineView_setObjectValue_forTableColumn_byItem(view, value, column, item)
    item.rename_to value
  end
  
  def open_selected_file(outline_view)
    item = selected_item
    if item.directory?
      @view.expandItem(item)
    else
      @app_controller.open_file item.path
      @app_controller.focus_to_file_list
    end
  end
  
  def refresh
    @roots.children.each {|item| refresh_item(item) } # @view.reloadItem_reloadChildren(item, true) }
  end
  
  def refresh_item(item)
    return unless item.has_loaded_children?
    item.refresh_children unless @view.isItemExpanded(item)

    old = item.children.map {|child| child.name }
    current = Dir["#{item.path}/*"].each {|name| File.basename(name) }
    
    if old != current
      item.refresh_children
      @view.reloadItem_reloadChildren(item, true)
    else
      item.children.each {|child| refresh_item(child) }
    end
  end
  
  private
  
  def file_item(item)
    item || @roots
  end
  
  def selected_item
    @view.itemAtRow(@view.selectedRow)
  end

  class Roots
    attr_writer :children
    
    def children
      @children ||= []
    end
    
    def directory?
      true
    end    
  end
  
  class FileItem < OSX::NSObject
    attr_accessor :path
    
    def init_with_path(path)
      @path = path
      self
    end
    
    def name
      File.basename(@path)
    end
    
    def has_loaded_children?
      !!@children
    end
    
    def children
      @children ||= Dir["#{@path}/*"].map {|path| FileItem.alloc.init_with_path(path) }
    end
    
    def refresh_children
      @children = nil
    end
    
    def directory?
      File.directory? @path
    end
    
    def rename_to(name)
      new_path = "#{File.dirname(@path)}/#{name}"
      return if File.exist?(new_path)

      FileUtils.mv(@path, new_path)
      @path = new_path if File.exist?(new_path)
    end
  end
end
