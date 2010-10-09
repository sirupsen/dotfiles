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

namespace :git do
  namespace :setup do
    desc "Setup Git and Github"
    task :git do
      git = {
              :git_name => 'user.name',
              :user_email => 'user.email',
              :github_user => 'github.user',
              :github_token => 'github.token',
            }

      Empty = "\n"
      GitGlobalConfig = 'git config --global'

      git.each do |name, command|
        if `#{GitGlobalConfig} #{command}` == Empty
          print "#{name}: "
          `#{GitGlobalConfig} #{command} "#{$stdin.gets}"`
        else
          puts "#{command} already set to: " + `#{GitGlobalConfig} #{command}`.strip
        end
      end
    end

    desc "Setup SSH for Github"
    task :ssh do
      unless File.exist?(".ssh/id_rsa.pub")
        print "Email: "
        `ssh-keygen -t rsa -C #{$stdin.gets}`
      else
        puts "SSH key already generated."
      end

      puts "Add it to your account at https://github.com/account\n\n"
      puts File.read(".ssh/id_rsa.pub")
    end

    desc "Setup SSH and Git"
    task :all do
      Rake::Task['git:setup:git'].invoke
      Rake::Task['git:setup:ssh'].invoke
    end
  end
end
