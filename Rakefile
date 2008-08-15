require 'osx/cocoa' # dummy
require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'erb'
require 'pathname'
require 'spec/rake/spectask'

# Application own Settings
APPNAME   = "Chizzle"
APPVERSION   = "0.1"
TARGET    = "#{APPNAME}.app"
RESOURCES = ['lib', 'config', '*.lproj', 'Credits.*', '*.icns']
PKGINC    = [TARGET, 'README', 'html', 'client']
LOCALENIB = [] #['Japanese.lproj/Main.nib']
PUBLISH   = 'yourname@yourhost:path'

BUNDLEID  = "rubyapp.#{APPNAME}"

CLEAN.include ['**/.*.sw?', '*.dmg', TARGET, 'image', 'a.out']

# Tasks
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end

task :default => [:debug]

desc 'Create Application Bundle and Run it.'
task :open => [:bundle] do
	sh %{open '#{TARGET}'}
end

task :debug => [:bundle] do
  load File.dirname(__FILE__) + "/chizzle"
end

desc 'Create .dmg file for Publish'
task :package => [:clean, 'pkg', :bundle] do
	name = "#{APPNAME}.#{APPVERSION}"
	sh %{
	mkdir image
	cp -r #{PKGINC.join(' ')} image
	ln -s html/index.html image/index.html
	}
	puts 'Creating Image...'
	sh %{
	hdiutil create -volname #{name} -srcfolder image #{name}.dmg
	rm -rf image
	mv #{name}.dmg pkg
	}
end

desc 'Publish .dmg file to specific server.'
task :publish => [:package] do
	sh %{
	svn log > CHANGES
	}
	_, host, path = */^([^\s]+):(.+)$/.match(PUBLISH)
	path = Pathname.new path
	puts "Publish: Host: %s, Path: %s" % [host, path]
	sh %{
	scp pkg/IIrcv.#{APPVERSION}.dmg #{PUBLISH}/pkg
	scp CHANGES #{PUBLISH}/pkg
	scp -r html/* #{PUBLISH}
	}
end

# desc 'Make Localized nib from English.lproj and Lang.lproj/nib.strings'
# rule(/.nib$/ => [proc {|tn| File.dirname(tn) + '/nib.strings' }]) do |t|
#   p t.name
#   lproj = File.dirname(t.name)
#   target = File.basename(t.name)
#   sh %{
#   rm -rf #{t.name}
#   nibtool -d #{lproj}/nib.strings -w #{t.name} English.lproj/#{target}
#   }
# end

# File tasks
desc 'Make executable Application Bundle'
task :bundle => [:clean, :compile] do
	sh %{
	mkdir -p "#{APPNAME}.app/Contents/MacOS"
	mkdir    "#{APPNAME}.app/Contents/Resources"
	cp -rp #{RESOURCES.join(' ')} "#{APPNAME}.app/Contents/Resources"
	echo -n "APPL????" > "#{APPNAME}.app/Contents/PkgInfo"
	echo -n #{APPVERSION} > "#{APPNAME}.app/Contents/Resources/APPVERSION"
	}
  # cp '#{APPNAME}' "#{APPNAME}.app/Contents/MacOS"
  # cp_r FileList["lib/*"].to_a, "#{APPNAME}.app/Contents/Resources"
	File.open("#{APPNAME}.app/Contents/Info.plist", "w") do |f|
		f << ERB.new(File.read("Info.plist.erb")).result
	end
end

task :compile do
  build_dir = "#{APPNAME}.app/Contents/MacOS"
  mkdir_p build_dir

	# Universal Binary
	sh %{gcc -arch ppc -arch i386 -Wall -lobjc -framework RubyCocoa main.m -o '#{build_dir}/#{APPNAME}'}
end

directory 'pkg'

