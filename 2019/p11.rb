require './intcode.rb'

@a = IO.read("in11.txt").split(",").map(&:to_i)

def run(hull)

	engine = IntCode.new(@a)

	directions = [[0,1], [1,0], [0,-1], [-1,0]]

	x = 0
	y = 0
	d = 0

	until engine.halt
		k = [x,y]
		in_color = hull[k] || 0
		engine.push(in_color)
		out_color, turn = engine.run
		hull[k] = out_color if out_color
		d += turn == 0 ? -1 : 1
		d = d % 4
		x += directions[d][0]
		y += directions[d][1]
	end

	hull
end

# part 1
puts run({}).size

# part 2

hull = run({[0,0] => 1})
x_min = hull.keys.map{|x,y|x}.min
y_min = hull.keys.map{|x,y|y}.min
x_max = hull.keys.map{|x,y|x}.max
y_max = hull.keys.map{|x,y|y}.max

y_max.downto(y_min){|y|
	x_min.upto(x_max){|x|
		print case hull[[x,y]]
		when 1 then '■'
		else
			' '
		end
	}
	puts
}