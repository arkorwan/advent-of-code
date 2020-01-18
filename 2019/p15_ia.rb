require './intcode.rb'
require 'curses'

include Curses

init_screen
curs_set(0)
noecho

a = IO.read("in15.txt").split(",").map(&:to_i)

engine = IntCode.new(a)

begin
  	win = Curses::Window.new(0, 0, 1, 2)
  	quit = false
  	found = -1
  	x = 40
  	y = 25

  	h = {[x,y] => 0}
  	d = 0

  	start = [x, y]

  	win.setpos(y, x)
	win.addstr("@")
	while true

		input = win.getch
		break if input == 'q'

		code, direction = case input
		when 'a' then [3, [-1, 0]]
		when 'w' then [1, [0, -1]]
		when 's' then [2, [0, 1]]
		when 'd' then [4, [1, 0]]
		else
			[-1, nil]
		end

		if code > 0
			tp = [x+direction[0], y+direction[1]]

			engine.push(code)
			
			case engine.run[0]
			when 0
				win.setpos(tp[1], tp[0])
				win.addstr("■")
			when 1
				win.setpos(y, x)
				win.addstr([x, y] == start ? "^" : ".")
				
				k = h[tp]
				h[tp] = d + 1 if k == nil || k > d +1
				d = h[tp]
				win.setpos(0,0)
				win.addstr(d.to_s + "   " + found.to_s + "    ")

				x = tp[0]
				y = tp[1]
				win.setpos(y, x)
				win.addstr("@")
			when 2
				win.setpos(y, x)
				win.addstr([x, y] == start ? "^" : ".")
				
				k = h[tp]
				h[tp] = d + 1 if k == nil || k > d +1
				d = h[tp]
				win.setpos(0,0)
				win.addstr(d.to_s + "   "+ found.to_s + "    ")
				
				x = tp[0]
				y = tp[1]
				win.setpos(y, x)
				win.addstr("!")	
				found = d
			end
			win.refresh
		end
		
	end

	win.getch
ensure
  	close_screen
end

