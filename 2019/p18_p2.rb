require 'set'
require 'pqueue'

m = "#############
#g#f.D#..h#l#
#F###e#E###.#
#dCba...BcIJ#
#####.@.#####
#nK.L...G...#
#M###N#H###.#
#o#m..#i#jk.#
#############"

m = IO.read('in18.txt')

@raw_map = m.split

stops = {}
shortest = {}

def is_door(c)
	c >= 'A' && c <= 'Z'
end

def is_key(c)
	c >= 'a' && c <= 'z'
end

def is_start(c)
	c >= '0' && c <= '3'
end

def shortest_key_paths(flood_map, start, start_key)
	map = flood_map.map{|r| r.clone}
	map[start[0]][start[1]] = 0

	q = []
	q << [start[0], start[1], Set.new]
	h = {}

	until q.empty?
		cy, cx, cdoors = q.shift
		cn = map[cy][cx] 
		[[0, 1], [0, -1], [1, 0], [-1, 0]].each{|dy, dx|
			py = cy + dy
			px = cx + dx
			if py >= 0 && py < map.size && px >= 0 && px < map[0].size && (map[py][px] || 0) > cn + 1
				map[py][px] = cn + 1
				r = @raw_map[py][px]
				pdoors = is_door(r) ? cdoors + [r.downcase] : cdoors
				if is_key(r)
					h[[start_key, r].join('')] = [cn+1, pdoors]
					pdoors += [r]
				end
				q << [py, px, pdoors]
			end
		}

	end

	h
end

orig = nil

@raw_map.each_with_index{|row, j| 
	row.each_char.with_index{|c, i|
		if c == '@'
			orig = [j, i]
			@raw_map[j-1][i-1] = '0'
			@raw_map[j-1][i] = '#'
			@raw_map[j-1][i+1] = '1'
			@raw_map[j][i-1] = '#'
			@raw_map[j][i] = '#'
			@raw_map[j][i+1] = '#'
			@raw_map[j+1][i-1] = '2'
			@raw_map[j+1][i] = '#'
			@raw_map[j+1][i+1] = '3'
			break
		end
	}
	break if orig
}


flood_map = []
key_chambers = {}

@raw_map.each_with_index{|row, j| 
	r = []
	row.each_char.with_index{|c, i|
		if is_start(c)
			stops[c] = [j, i]
			r << 1000000
		elsif is_key(c)
			stops[c] = [j, i]
			r << 1000000
			key_chambers[c] = if j < orig[0] && i < orig[1]
				0
			elsif j < orig[0]
				1
			elsif i < orig[1]
				2
			else
				3
			end
		elsif c == '#'
			r << nil
		else
			r << 1000000
		end	
	}
	flood_map << r
}

stops.each{|c, pos| shortest.merge!(shortest_key_paths(flood_map, pos, c)) }

start_node = [0, '0123', Set.new]

visited = Set.new

q = PQueue.new([start_node]){ |a,b| a[0] < b[0] }

rrr = 0

until q.empty? #|| rrr > 200000
 	cn, cks, ckeys = q.pop
 	if ckeys.size == stops.size - 4
 		p [cn, cks, ckeys]
 		break
 	end
 	next if visited.include?([cks, ckeys])
 	rrr += 1

	stops.keys.each{|dk|
 		next if is_start(dk) || ckeys.include?(dk)

 		xi = key_chambers[dk]
 		ck = cks[xi]
 		steps, pdoors = shortest["#{ck}#{dk}"]

		if pdoors.subset?(ckeys)
			nks = cks.clone
			nks[xi] = dk
 			node = [cn + steps, nks, ckeys + [dk]]
 			q << node
 		end
 		visited << [cks, ckeys]
 		
 	}

 	p [rrr, q.top] if rrr % 100 == 0
 end
