
apos = [
	[5,4,4],
	[-11,-11,-3],
	[0,7,0],
	[-13,2,10]
]

pos = apos.map(&:clone)

vel = Array.new(4).map{[0,0,0]}

# part 1

1000.times{
	4.times.to_a.combination(2){|i,j|
		3.times{|k|
			g = pos[i][k] <=> pos[j][k]
			vel[i][k] -= g
			vel[j][k] += g
		}		
	}
	4.times{|i|
		3.times{|k|
			pos[i][k] += vel[i][k]
		}
	}

}

p 4.times.map{|i| pos[i].map(&:abs).sum * vel[i].map(&:abs).sum}.sum

# part 2

def sim(a)

	pos = a.clone
	vel = [0,0,0,0]

	step = 0
	while true
		step += 1
		[0,1,2,3].combination(2){|i,j|
			g = pos[i] <=> pos[j]
			vel[i] -= g
			vel[j] += g
		}
		4.times{|i| pos[i] += vel[i]}
		return step if vel == [0,0,0,0] && pos == a
	end
end

def lcm(a,b,c)
	ab = a*b / a.gcd(b)
	ab * c / ab.gcd(c)
end

periods = apos.transpose.map{|w|sim(w)}
p lcm(*periods)
