require 'rubygems' unless defined? Gem # only needed in 1.8

begin 
  require 'irbtools' 
rescue LoadError
  puts 'IRBtools not installed -- ohai IRB!'
end

# Easily print methods local to an object's class
class Object
  def local_methods
    (methods - Object.instance_methods).sort
  end
end

if defined? ActiveRecord
  def explain(query)
    ActiveRecord::Base.connection.execute("EXPLAIN #{query}")
  end
end
