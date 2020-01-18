require 'set'
require 'pqueue'

m = "#################
#i.G..c...e..H.p#
########.########
#j.A..b...f..D.o#
########@########
#k.E..a...g..B.n#
########.########
#l.F..d...h..C.m#
#################"

#m = IO.read('in18.txt')

@raw_map = m.split

stops = {}
shortest = {}

def is_door(c)
	c >= 'A' && c <= 'Z'
end

def is_key(c)
	c >= 'a' && c <= 'z'
end

def shortest_key_paths(flood_map, start, start_key)
	map = flood_map.map{|r| r.clone}
	map[start[0]][start[1]] = 0

	q = []
	q << [start[0], start[1], Set.new]
	h = {}

	until q.empty?
		cy, cx, cdoors, ckeys = q.shift
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

flood_map = []

@raw_map.each_with_index{|row, j| 
	r = []
	row.each_char.with_index{|c, i|
		if c == '@'
			stops['@'] = [j, i]
			r << 1000000
		elsif is_key(c)
			stops[c] = [j, i]
			r << 1000000
		elsif c == '#'
			r << nil
		else
			r << 1000000
		end	
	}
	flood_map << r
}

stops.each{|c, pos| shortest.merge!(shortest_key_paths(flood_map, pos, c)) }

start_node = [0, '@', Set.new]

visited = Set.new

q = PQueue.new([start_node]){ |a,b| a[0] < b[0] }

rrr = 0

until q.empty? #|| rrr > 200000
	rrr += 1
	cn, ck, ckeys = q.pop
	if ckeys.size == stops.size - 1
		p [cn, ck, ckeys]
		break
	end
	next if visited.include?([ck, ckeys])
	stops.keys.each{|dk|
		next if dk == '@' || ckeys.include?(dk)
		steps, pdoors = shortest["#{ck}#{dk}"]
		if pdoors.subset?(ckeys)
			node = [cn + steps, dk, ckeys + [dk]]
			q << node
		end
		visited << [ck, ckeys]
	}

	p [rrr, q.top[0]] if rrr % 100 == 0
end

# [159700, 4192]
# [6900, 3846]