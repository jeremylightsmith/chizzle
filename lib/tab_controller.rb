class TabController < OSX::NSObject
  attr_accessor :tab_view
  
  def next_tab
    select_tab {|index, count| (index + 1) % count }
  end
  
  def previous_tab
    select_tab {|index, count| (index + count - 1) % count }
  end
  
  private 
  
  def select_tab
    count = items.size
    return if count == 0
    
    @tab_view.selectTabViewItemAtIndex(yield(selected_index, count))
  end
  
  def selected_index
    @tab_view.indexOfTabViewItem(@tab_view.selectedTabViewItem)
  end
  
  def items
    @tab_view.tabViewItems
  end
end