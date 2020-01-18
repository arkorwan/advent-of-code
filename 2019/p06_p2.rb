g = {}
IO.foreach('in06.txt'){|l|
	a = l.strip.split(')')
	g[a[0]] ||= [nil]
	g[a[1]] ||= [nil]
	p 'warn!!! multiple parents!' if g[a[1]][0]
	g[a[1]][0] = a[0]
	
}

def prefix(g, n)
	s =[]
	node = g[n]
	while node[0]
		parent = g[node[0]]
		s << node[0]
		node = parent
	end
	s.reverse
end

p0 = prefix(g, 'YOU')
p1 = prefix(g, 'SAN')

i = 0
i+= 1 while p0[i] == p1[i]

p p0.size + p1.size - 2*i
