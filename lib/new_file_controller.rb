class NewFileController < OSX::NSObject
  ib_outlet :app_controller, :location_field, :name_field, :window
  
  def show
    @location_field.setStringValue File.expand_path(@app_controller.selected_directory)
    @window.makeKeyAndOrderFront(nil)
  end
  
  def create
    file = File.join(@location_field.stringValue.to_s, @name_field.stringValue.to_s)
    
    alert("file '#{file}' already exists") and return if File.exist?(file)
    alert("directory '#{File.dirname(file)}' doesn't exist") and return if !File.directory?(File.dirname(file))

    File.open(file, 'w') {}
    @window.close
    @app_controller.open_file(file)
    @app_controller.refresh
  end
  
  def cancel
    @window.close
  end
end
