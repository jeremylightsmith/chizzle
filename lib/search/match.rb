class Match
  attr_reader :display_name, :file, :offset
  
  def initialize(display_name, file, offset)
    @display_name, @file, @offset = display_name, file, offset
    self
  end

  def <=>(other)
    result = self.display_name <=> other.display_name
    return result unless result == 0

    result = self.file <=> other.file
    return result unless result == 0
    
    result = self.offset <=> other.offset
    return result unless result == 0
  end
end
