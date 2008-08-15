require 'search/match'

class FileFinderStrategy
  def initialize(project)
    @project = project
  end
  
  def find_matches(pattern)
    pattern = pattern.downcase
    regex_pattern = pattern.split('').collect{|c| "(#{c})"}.join('.*')
    Dir[@project.root + "/**/*"].
      find_all do |fullname|
        name = File.basename(fullname).downcase
        name =~ /#{regex_pattern}/ && !File.directory?(fullname)
      end.map do |fullname|
        Match.new(File.basename(fullname), fullname, 0)
      end
  end
end