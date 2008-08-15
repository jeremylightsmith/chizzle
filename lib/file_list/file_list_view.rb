require 'keys'

class FileListView < OSX::NSOutlineView
  def keyDown(event)
    case event.keyCode
    when Keys::RETURN: delegate.open_selected_file(self)
    else              super_keyDown(event)
    end
  end
end