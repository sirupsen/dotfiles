hello_world = lambda do |env| 
  [200, {"Content-Type" => "text/html"}, ["<h1>Start working!</h1>"]]
end

run hello_world
