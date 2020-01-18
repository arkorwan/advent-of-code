g = {}
IO.foreach('in06.txt'){|l|
	a = l.strip.split(')')
	g[a[0]] ||= [nil, 0, 0]
	g[a[1]] ||= [nil, 0, 0]
	p 'warn!!! multiple parents!' if g[a[1]][0]
	g[a[1]][0] = a[0]
	g[a[0]][1] += 1
	
}

leaves = []
g.each{|k, v|
	leaves << k if v[1] == 0
}


until leaves.empty?
 	l = leaves.pop
 	node  = g[l]
 	parent = g[node[0]]
 	if parent
 		parent[2] += node[2] + 1
 		parent[1] -= 1
 		leaves << node[0] if parent[1] == 0
 	end
 	
end

p g.each.map{|k, v| v[2]}.sum