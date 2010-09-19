require 'fileutils' 

HOME = Dir.home + '/'
DIRNAME = File.dirname(__FILE__) + '/'

NON_CONFIG_FILES = %w{. .. Rakefile}

task :install do
  Dir.foreach(".") do |file|
    File.symlink(DIRNAME + file, HOME + file) unless NON_CONFIG_FILES.include?(file)
  end
end

task :delete do
  Dir.foreach(".") do |file|
    if File.exist?(HOME + file)
      FileUtils.rm_rf(HOME + file) unless [".", ".."].include?(file)

      puts file + " is now deleted."
    else

      puts file + " doesn't exists."
    end
  end
end
