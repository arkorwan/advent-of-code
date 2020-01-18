map_text = IO.read('in20.txt').split("\n")

y = map_text.size - 4
x = map_text[0].size - 4
h = 0
h += 1 until map_text[2+h][2+h] == ' '

mp = Array.new(y).map{Array.new(x)}
y.times{|j| x.times{|i|
	#next if j >= h && j < y-h && i >= h && i < x-h
	mp[j][i] = 2<<29 if map_text[2+j][2+i] == '.'
}}

@start = nil
@target = nil
@temp_portal = {}
@portals = {}

def inbound(j, i, y, x, h)
	j >= 0 && j < y && i >= 0 && i < x && !(j >= h && j < y-h && i >= h && i < x-h)
end

def portal_door(j, i, y, x, h)
	[[j-1, i], [j+1, i], [j, i-1], [j, i+1]].select{|pj, pi| inbound(pj, pi, y, x, h)}[0]
end

def handle_portal(j, i, y, x, h, lbl, dlvl)

	if lbl == 'AA'
		@start = portal_door(j, i, y, x, h)
	elsif lbl == 'ZZ'
		@target = portal_door(j, i, y, x, h)
	elsif not lbl.include?(' ')
		k = @temp_portal[lbl]
		if k
			@portals[k] = portal_door(j, i, y, x, h) << (-dlvl)
			@portals[[j, i]] = portal_door(k[0], k[1], y, x, h) << dlvl
			@temp_portal.delete(lbl)
		else
			@temp_portal[lbl] = [j, i]
		end
	end

end

y.times{|j|
	handle_portal(j, -1, y, x, h, map_text[2+j][0..1], -1)
	handle_portal(j, x, y, x, h, map_text[2+j][x+2..x+3], -1)
}
x.times{|i|
	handle_portal(-1, i, y, x, h, map_text[0..1].map{|r| r[2+i]}.join(''), -1)
	handle_portal(y, i, y, x, h, map_text[y+2..y+3].map{|r| r[2+i]}.join(''), -1)
}
h.upto(y-h-1){|j|
	handle_portal(j, h, y, x, h, map_text[2+j][h+2..h+3], 1)
	handle_portal(j, x-h-1, y, x, h, map_text[2+j][x-h..x-h+1], 1)	
}
h.upto(x-h-1){|i|
	handle_portal(h, i, y, x, h, map_text[h+2..h+3].map{|r| r[2+i]}.join(''), 1)
	handle_portal(y-h-1, i, y, x, h, map_text[y-h..y-h+1].map{|r| r[2+i]}.join(''), 1)	
}

found = false

# part 1

# mp[@start[0]][@start[1]] = 0
# q = [@start]

# until found
# 	current = q.shift
# 	n = mp[current[0]][current[1]]
# 	[[0, 1], [0, -1], [1, 0], [-1, 0]].each{|dy, dx|
# 		nby = current[0] + dy
# 		nbx = current[1] + dx
# 		t = @portals[[nby, nbx]] || (mp[nby][nbx] && [nby,nbx])
# 		if t && mp[t[0]][t[1]] > n + 1
# 			mp[t[0]][t[1]] = n + 1
# 			q << t[0..1]

# 			if t[0..1] == @target
# 				puts n + 1
# 				found = true
# 				break
# 			end

# 		end
# 	}
	
# end

# part 2

found = false

@start << 0
@target << 0

lvls = [mp.map(&:clone)]
lvls[0][@start[0]][@start[1]] = 0
q = [@start]


until q.empty? || found
	current = q.shift
	n = lvls[current[2]][current[0]][current[1]]
	[[0, 1], [0, -1], [1, 0], [-1, 0]].each{|dy, dx|
		nby = current[0] + dy
		nbx = current[1] + dx
		pt = @portals[[nby, nbx]]
		t = nil
		if pt && current[2] + pt[2] >= 0
			t = pt.clone
			t[2] += current[2]
			lvls << mp.map(&:clone) if t[2]+1 > lvls.size
		elsif mp[nby] && mp[nby][nbx]
			t = [nby, nbx, current[2]]
		end

		if t && lvls[t[2]][t[0]][t[1]] > n + 1
			lvls[t[2]][t[0]][t[1]] = n + 1
			q << t
			if t == @target
				puts n + 1
				found = true
				break
			end

		end
	}
	
end

# lvls.each.with_index{|lvl, i|
# 	puts "LEVEL #{i}"
# 	lvl.each{|r|
# 		p r.map{|k| ((k || 9999)+10000) % 100000  }
# 	}
	
# }