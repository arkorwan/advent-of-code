input = IO.foreach('../data/20.txt').map(&:strip)

class M
  attr_accessor :module_type, :destinations

  def initialize(tpe, dests)
    @module_type = tpe
    @destinations = dests
  end
end

modules = {}
input.each{|line|
  src, dst = line.split(" -> ")
  label = src[1..-1]
  modules[label] = M.new(src[0], dst.split(', '))
}
# add modules with no destinations
modules.values.each{|m|
  m.destinations.each{ modules[_1] ||= M.new("output", []) }
}

flipflop_states = modules.filter{|label, m| m.module_type == "%"}.map{ |label, m| [label, 0]}.to_h
conjunction_states = {}
modules.each{|label, m|
  m.destinations.each{|dst|
    if modules[dst].module_type == "&"
      conjunction_states[dst] ||= {}
      conjunction_states[dst][label] = 0
    end
  }
}

counter = [0, 0]

# rx is a single output from a conjuction.
# Each input to this conjuction is periodic, firing 1 once every t pushes.
target_conj = modules.find{|label, m| m.destinations.include?("rx")}[0]
target_conj_inputs = conjunction_states[target_conj].keys
target_rounds = {}

pushes = 0

while target_rounds.size < target_conj_inputs.size

  pushes += 1
  queue = [["button", "roadcaster", 0]]
  until queue.empty?
    src, dst, signal = queue.pop

    counter[signal] += 1  
    if signal == 0 && target_conj_inputs.include?(dst) && target_rounds[dst] == nil
      target_rounds[dst] = pushes
    end

    case modules[dst].module_type
    when "b"
      modules[dst].destinations.each{ queue.unshift([dst, _1, signal])}
    when "%"
      next if signal == 1
      flipflop_states[dst] ^= 1
      out_signal = flipflop_states[dst]
      modules[dst].destinations.each{ queue.unshift([dst, _1, out_signal])}
    when "&"
      conjunction_states[dst][src] = signal
      out_signal = conjunction_states[dst].values.all?{_1 == 1} ? 0 : 1
      modules[dst].destinations.each{ queue.unshift([dst, _1, out_signal])}
    end
  end

  # part 1
  p counter[0]*counter[1] if pushes == 1000

end

# part 2
p target_rounds.values.reduce(:lcm)
