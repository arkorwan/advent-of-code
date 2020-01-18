require './intcode.rb'
require 'curses'

include Curses

a = IO.read("in13.txt").split(",").map(&:to_i)
a[0] = 2

engine = IntCode.new(a)
score = 0

init_screen
start_color

init_pair(COLOR_CYAN, COLOR_CYAN, COLOR_BLACK)
init_pair(COLOR_GREEN, COLOR_GREEN, COLOR_BLACK)
init_pair(COLOR_MAGENTA, COLOR_MAGENTA, COLOR_BLACK)
curs_set(0)
noecho

begin
  	quit = false
  	ball_direction = 0
  	ball_x = nil
  	player_x = nil
	until quit || engine.halt
		outputs = engine.run
		outputs.each_slice(3){|x,y,v|
			if x == -1
				setpos(0, 20)
				attron(color_pair(0)){
		    	  addstr("score: #{v}")
		    	}
			else
				setpos(y + 2, x + 20)
				case v
				when 0
					addstr(' ')
				when 1
					attron(color_pair(COLOR_MAGENTA)){
			    	  addstr('#')
			    	}
				when 2
					attron(color_pair(COLOR_GREEN)){
			    	  addstr('■')
			    	}
				when 3
					player_x = x
					attron(color_pair(COLOR_CYAN)){
			    	  addstr('=')
			    	}
				when 4
					ball_x = x
					addstr('O')
				else
					addstr(' ')
				end
				
			end
		}
		refresh
		sleep(0.003)
		code = if player_x > ball_x + ball_direction
			-1
		elsif player_x < ball_x + ball_direction
			1
		else
			0
		end

		engine.push(code)
				
	end
	getch
ensure
  	close_screen
end

