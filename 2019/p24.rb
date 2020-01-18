require 'set'

state = "
..#.#
.#.##
##...
.#.#.
###..".strip.split

def empty_state(d)
	["."*d]*d
end

def evolve(s)
	t = []
	d = s.size
	d.times{|j|
		r = ""
		d.times{|i|
			n = 0
			n += 1 if j+1 < d && s[j+1][i] == '#'
			n += 1 if j-1 >= 0 && s[j-1][i] == '#'
			n += 1 if i+1 < d && s[j][i+1] == '#'
			n += 1 if i-1 >= 0 && s[j][i-1] == '#'
			c = n == 1 || (n == 2 && s[j][i] == '.') ? '#' : '.'
			r << c
		}
		t << r
	}
	t
end

def evolve_recursive(s, contained, container)
	t = []
	d = s.size
	mid = d / 2
	s.size.times{|j|
		r = ""
		s[0].size.times{|i|
			if i == mid && j == mid
				r << '?'
				next
			end 

			n = 0

			# north
			if j == 0
				n += 1 if container && container[mid-1][mid] == '#'
			elsif j == mid + 1 && i == mid
				d.times{|k| n += 1 if contained[-1][k] == '#' } if contained
			else
				n += 1 if s[j-1][i] == '#'
			end

			# west
			if i == 0
				n += 1 if container && container[mid][mid-1] == '#'
			elsif i == mid + 1 && j == mid
				d.times{|k| n += 1 if contained[k][-1] == '#' } if contained
			else
				n += 1 if s[j][i-1] == '#'
			end

			# south
			if j == d-1
				n += 1 if container && container[mid+1][mid] == '#'
			elsif j == mid - 1 && i == mid
				d.times{|k| n += 1 if contained[0][k] == '#' } if contained
			else
				n += 1 if s[j+1][i] == '#'
			end

			# east
			if i == d-1
				n += 1 if container && container[mid][mid+1] == '#'
			elsif i == mid - 1 && j == mid
				d.times{|k| n += 1 if contained[k][0] == '#' } if contained
			else
				n += 1 if s[j][i+1] == '#'
			end

			c = n == 1 || (n == 2 && s[j][i] == '.') ? '#' : '.'
			r << c
		}
		t << r
	}
	t

end

def biodiversity(s)
	b = 1
	n = 0
	d = s.size
	d.times{|j| d.times{|i|
		n += b if s[j][i] == '#'
		b <<= 1
	}}
	n
end


def part1(state)
	s = Set.new

	s << biodiversity(state)

	i = 0
	while i < 1000
		state = evolve(state)
		bio = biodiversity(state)
		if s.include?(bio)
			puts bio
			break
		end
		s << bio
		i += 1
	end

	puts i
end

def part2(state, rounds)

	floors = [state]
	max_floor = 0

	d = state.size
	empty = empty_state(d)
	
	rounds.times{|r|
		new_max_floor = r/2 + 1
		new_floors = Array.new(new_max_floor * 2 + 1)
		(-new_max_floor).upto(new_max_floor){|f|
			current = f < -max_floor || f > max_floor ? empty : floors[f] 
			container = f-1 < -max_floor ? empty : floors[f-1]
			contained = f+1 > max_floor ? empty : floors[f+1]
			#p [current, contained, container]
			new_floors[f] = evolve_recursive(current, contained, container)
		}

		floors = new_floors
		max_floor = new_max_floor

		#floor_print(floors)
		#puts

	}

	p floors.map{|f|f.map{|r| r.count('#')}.sum}.sum

end

def floor_print(floors)
	m = floors.size / 2
	d = floors[0].size

	d.times{|j|
		print '|'
		(-m).upto(m){|f|
			print floors[f][j]
			print '|'
		}
		puts
	}
	
end

part2(state, 200)