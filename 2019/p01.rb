input = IO.foreach('in01.txt').to_a

# part 1
p input.map{|a|a.to_i/3-2}.sum

# part 2
p input.map{|a| 
	s = 0
	t = a
	begin
		t = t.to_i / 3 - 2
		t = 0 if t < 0
		s += t
	end until t == 0
	s
}.sum