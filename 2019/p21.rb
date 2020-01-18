require './intcode.rb'

a = IO.read("in21.txt").split(",").map(&:to_i)
engine =IntCode.new(a)

puts engine.run_string

# part 1:

engine.push_string('NOT C J')
engine.push_string('AND D J')
engine.push_string('NOT A T')
engine.push_string('OR T J')
engine.push_string('WALK')

puts engine.run_string
puts
# part 2:

engine =IntCode.new(a)

puts engine.run_string

engine.push_string('NOT C J')
engine.push_string('AND D J')
engine.push_string('OR E T')
engine.push_string('OR H T')
engine.push_string('AND T J')
engine.push_string('NOT A T')
engine.push_string('OR T J')
engine.push_string('OR B T')
engine.push_string('OR E T')
engine.push_string('NOT T T')
engine.push_string('OR T J')
engine.push_string('RUN')

puts engine.run_string
