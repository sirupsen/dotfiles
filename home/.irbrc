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
    query = query.to_sql if query.is_a?(ActiveRecord::Relation)

    ActiveRecord::Base.connection
      .execute("EXPLAIN ANALYZE #{query}") 
      .to_a
      .each { |hash| puts hash["QUERY PLAN"] }

    nil
  end
end

# http://ozmm.org/posts/time_in_irb.html
def time(times = 1)
  require 'benchmark'

  ret = nil
  Benchmark.bm { |x| x.report { times.times { ret = yield } } }
  ret
end

