require 'open3'

class ScriptRunner
  def initialize(view)
    @view = view
  end
  
  def run_file(file_name)
    # todo this should be asynchronous
    Dir.chdir(File.dirname(file_name)) do
      command = "ruby #{File.basename(file_name)}\n"
    
      @view.setString ""
      @view.insertText "> #{command}"

      stdin, stdout, stderr = Open3.popen3(command)

      @stdout_thread = attach_output(stdout)
      @stderr_thread = attach_output(stderr)
    end
  end
  
  def run_file_synchronously(file_name)
    run_file(file_name)
    @stdout_thread.join
    @stderr_thread.join
  end
  
  def attach_output(output)
    Thread.start(@view, output) do |view, stdout|
      begin
        while line = output.gets
          view.insertText line
        end
      rescue EOFError
      end
    end
  end
end