class SymbolTable
  def initialize(project)
    @project = project
  end
end

class Project
  attr_accessor :root
  
  def initialize(root)
    @root = root
    @symbol_table = SymbolTable.new(self)
  end
  
  def make_project_relative(file)
    file[@root.length + 1..-1]
  end
end