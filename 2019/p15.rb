require './intcode.rb'

a = IO.read("in15.txt").split(",").map(&:to_i)

# code, dx, dy
inputs = [
	[1, 0, -1],
	[2, 0, 1],
	[3, -1, 0],
	[4, 1, 0]
]

# part 1

oxygen = nil

start = [0, 0]

h = {start => [IntCode.new(a), 0]}

q = [start]

until q.empty?

	pos = q.shift
	
	c_engine, c_steps = h[pos]
		
	inputs.each{|code, dx, dy|

		nx = [pos[0]+dx, pos[1]+dy]
		x = h[nx]
		if x == nil || x[1] > c_steps + 1
			engine = c_engine.clone
			engine.push(code)
			case engine.run[0]
			when 0
				h[nx] = [nil, -1]
			when 1
				h[nx] = [engine, c_steps + 1]
				q << nx
			when 2
				h[nx] = [engine, c_steps + 1]
				q << nx
				oxygen = nx
				puts c_steps + 1
			end
		end

	}

end

# part 2

g = {oxygen => 0}
q = [oxygen]

mx = 0
until q.empty?
	node = q.shift
	k = g[node]
	inputs.each{|code, dx, dy|
		new_node = [node[0] + dx, node[1] + dy]
		if h[new_node][1] > -1 && (g[new_node] == nil || g[new_node] > k + 1) 
			g[new_node] = k + 1
			q << new_node 
			mx = k + 1
		end
	}

end

p mx