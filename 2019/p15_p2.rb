
a = IO.foreach("map15.txt").to_a.map
h = {}
q = []

a.each_with_index{|l, y|
	l.each_char.with_index{|c, x|
		case c
		when '.'
			h[[x, y]] = -1
		when '^'
			h[[x, y]] = -1
		when 'X'
			h[[x, y]] = 0
			q << [x, y]
		end
	}
}

directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]


until q.empty?
	node = q.shift
	k = h[node]
	directions.each{|dx, dy|
		new_node = [node[0] + dx, node[1] + dy]
		if h[new_node] == -1
			h[new_node] = k + 1
			q << new_node 
		end
	}

end

p h.values.max

