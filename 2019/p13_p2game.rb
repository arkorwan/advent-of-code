require './intcode.rb'
require 'curses'

include Curses

MAX_INDEX = 40
MIN_INDEX = 0

@index = 0

init_screen
start_color

init_pair(1, COLOR_RED, COLOR_BLACK)
curs_set(0)
noecho

a = IO.read("in13.txt").split(",").map(&:to_i)
a[0] = 2

engine = IntCode.new(a)
score = 0

begin
  	win = Curses::Window.new(0, 0, 1, 2)
  	quit = false
	until quit || engine.halt
		outputs = engine.run
		outputs.each_slice(3){|x,y,v|
			if x == -1
				win.setpos(0, 0)
				win.addstr(v.to_s)
			else
				win.setpos(y + 2, x)
				output_char = case v
				when 0 then ' '
				when 1 then '#'
				when 2 then '*'
				when 3 then '█'
				when 4 then 'O'
				else
					' '
				end
  				win.addstr(output_char)
			end
		}
		win.refresh
		input = win.getch
		if input == 'q'
			quit = true
		else
			code = case input
			when 'z' then -1
			when 'c' then 1
			else
				0
			end
			engine.push(code)
		end
		
	end
ensure
  	close_screen
end

