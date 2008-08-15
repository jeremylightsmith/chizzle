def a
  raise "something really bad happened"
end

def b
  a
end

def c 
  b
end

c