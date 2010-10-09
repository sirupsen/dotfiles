require 'rubygems'
require 'rake'

namespace :gems do
  namespace :irb do
    desc "Install required IRB gems"
    task :install do
      `gem install irbtools`
      `gem install irb_rocket --source http://merbi.st`
    end
  end

  namespace :test do
    namespace :autotest do
      desc "Install AutoTest gems"
      task :install do
        # http://ph7spot.com/musings/getting-started-with-autotest
        `gem install ZenTest autotest-rails`
      end
    end
  end

  namespace :rvm do
    namespace :global do
      desc "Install global RVM gems"
      task :install do
        # Install irbtools stuff
        Rake::Task['gems:irb:install'].invoke

        `gem install rake bundler`
      end
    end
  end
end
