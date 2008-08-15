class GotoLineController < OSX::NSObject
  ib_outlet :app_controller, :line_field, :window
  
  def show
    return unless editor
    
    @line_field.setStringValue ""
    @window.makeKeyAndOrderFront(nil)
  end
  
  def go
    line = @line_field.stringValue.to_s
    
    if line != line.to_i.to_s
      alert("line should be a number")
      return
    end
    
    @window.close
    editor.goto_line(line.to_i)
  end
  
  def cancel
    @window.close
  end
  
  private 
  
  def editor
    @app_controller.selected_editor
  end
end
