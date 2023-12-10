input = IO.foreach('../data/08.txt').map(&:strip)

ops = input[0]

left = {}
right = {}
input[2..-1].each{|line| 
  parts = line.split(/[\s,\(\)]/)
  left[parts[0]] = parts[3]
  right[parts[0]] = parts[5]
}

def find(start, target, left, right, ops)
  node = start
  steps = 0
  
  until node.end_with? target
    d = ops[steps % ops.size]
    steps += 1
    node = d == 'L' ? left[node] : right[node]
  end
  steps
end

# part 1
p find('AAA', 'ZZZ', left, right, ops)

# part 2
starts = left.keys.filter{|node| node.end_with?'A'}
p starts.map{|start_node| find(start_node, 'Z', left, right, ops)}.reduce(:lcm)
