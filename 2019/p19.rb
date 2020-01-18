require './intcode.rb'

@a = IO.read("in19.txt").split(",").map(&:to_i)

def f(x, y)
	v = IntCode.new(@a)
	v.push(x)
	v.push(y)
	v.run[0]
end

# part 1
s = 0
50.times{|y|
	50.times{|x|
		k = f(x, y)
		s += k
		print k
	}
	puts
}

puts s

# part 2

m = 100

y = 10
x = 0
dx = -1
state = 0
stack = []
while true

	k = f(x, y)

	#p [x, y] if k == 1
	
	if state == 0 && k == 0
		x += 1
	elsif state == 0 && k == 1
		dx = x
		x = stack.empty? ? x + m-1 : stack[-1][1]
		state = 1
	elsif state == 1 && k == 1
		x += 1
	elsif state == 1 && k == 0
		diff = x - dx
		if diff >= m
			stack << [dx, x-1]
			if stack.size >= m && dx >= stack[-m][0] && dx + m-1 <= stack[-m][1]
				p dx * 10000 + (y-m+1)
				break
			end
		end
		x = dx
		dx = -1
		y += 1
		state = 0
	end
end
