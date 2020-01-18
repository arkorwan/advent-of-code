require './intcode.rb'

def draw(tiles)
	x_min = tiles.keys.map{|x,y|x}.min
	y_min = tiles.keys.map{|x,y|y}.min
	x_max = tiles.keys.map{|x,y|x}.max
	y_max = tiles.keys.map{|x,y|y}.max

	y_min.upto(y_max){|y|
		x_min.upto(x_max){|x|
			print case tiles[[x,y]]
			when 0 then ' '
			when 1 then '#'
			when 2 then '■'
			when 3 then '='
			when 4 then 'O'
			else
				' '
			end
		}
		puts
	}
	puts
end

a = IO.read("in13.txt").split(",").map(&:to_i)
tiles = IntCode.new(a).run.each_slice(3).to_a 

draw(tiles.map{|x,y,z| [[x,y],z]}.to_h)

p tiles.count{|x| x[2] == 2}