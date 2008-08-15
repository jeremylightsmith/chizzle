class SymbolFinder < OSX::NSObject
  attr_accessor :search_field, :matches_table, :strategy, :window
  
  def awakeFromNib
    @matches_table.setDoubleAction :accept
  end
  
  def initWithStrategy(strategy)
    @strategy = strategy
    @matches = []
    self
  end
  
  def show(parent)
    @search_field.setStringValue("")
    @window.makeKeyAndOrderFront(parent)
  end
  
  def search(field)
    @matches = @strategy.find_matches(@search_field.stringValue.to_s)
    @matches_table.reloadData
    select_row(0)
  end
  
  def control_textView_doCommandBySelector(control, text_view, selector)
    case selector
    when "moveDown:"
      select_row(@matches_table.selectedRow + 1)
    when "moveUp:"
      select_row(@matches_table.selectedRow - 1)
    when "insertNewline:"
      accept
    else
      return false
    end
    true
  end
  
  def on_accept(&block)
    @accept_block = block
  end
  
  def accept
    raise "no accept block was given, please call :on_accept" unless @accept_block
    match = @matches[@matches_table.selectedRow] || return

    @accept_block.call(match.file, match.offset)
    window.close
  end
  
  def numberOfRowsInTableView(table)
    @matches ? @matches.size : 0
  end

  def tableView_objectValueForTableColumn_row(table, column, row)
    @matches[row].display_name
  end
  
  private
  
  def select_row(i)
    i = 0 if i < 0
    i = @matches_table.numberOfRows - 1 if i >= @matches_table.numberOfRows
    
    @matches_table.selectRow_byExtendingSelection(i, false)
    @matches_table.scrollRowToVisible(i)
  end
end