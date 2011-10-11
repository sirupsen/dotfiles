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

  alias_method :lm, :local_methods
end

if defined? ActiveRecord
  def explain(query)
    ActiveRecord::Base.connection.execute("EXPLAIN #{query}")
  end
end

# http://ozmm.org/posts/time_in_irb.html
def time(times = 1)
  require 'benchmark'

  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end
