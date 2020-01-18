require './intcode.rb'

engine = IntCode.new(IO.read("in09.txt").split(",").map(&:to_i))
engine2 = engine.clone

engine.push(1)
p engine.run

engine2.push(2)
p engine2.run