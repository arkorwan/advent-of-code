require './intcode.rb'

a = IO.read("in25.txt").split(",").map(&:to_i)

engine = IntCode.new(a)

desc = nil
backup = nil

inv = [nil]
flush = true

def print_room_desc

end

while true

	if flush
	
		output = engine.run_string
		lines = output.split("\n")
		items = [nil]
		
		item_flag = false	
		desc_store = false

		lines.size.times{|i|

			desc_store = true if lines[i][0..2] == '== '
			item_flag = true if lines[i] == 'Items here:'
			
			if item_flag && lines[i][0..1] == '- '
				arg = lines[i][2..-1]
				lines[i] = "(#{items.size}): #{arg}"
				items << arg
			end
		}
		puts lines
		desc = lines if desc_store 
	end
	
	q = gets.strip

	flush = true

	if q == 'q'
		break
	elsif q == 'i'
		#engine.push_string('inv')
		# we maintain the inventory ourselves!
		if inv.size == 1
			puts "You've got nothing!"
		else
			puts "Items in your inventory:"
			inv.each_with_index{|item, i|
				next if i == 0
				puts "(#{i}): #{item}"
			}	
		end
		
	elsif q == 'n'
		engine.push_string('north')
	elsif q == 'e'
		engine.push_string('east')
	elsif q == 's'
		engine.push_string('south')
	elsif q == 'w'
		engine.push_string('west')
	elsif q[0..1] == 't ' 
		arg = q.split[-1].to_i
		if arg && arg < items.size && arg > 0
			backup = [engine.clone, inv.clone, desc.clone]
			item = items[arg]
			engine.push_string("take #{item}") 
			inv << item
			desc.delete("(#{arg}): #{item}")
		else
			puts "invalid take command."
		end
	elsif q[0..1] == 'd '
		arg = q.split[-1].to_i
		if arg && arg < inv.size && arg > 0
			engine.push_string("drop #{inv[arg]}")
			inv.delete_at(arg)
		else
			puts "invalid drop command."
		end
	elsif q == 'restore'
		if backup
			puts "restore game state from before you take the last item..."
			engine, inv, desc = backup
			backup = nil
			puts desc
		else
			puts "no backup available."
		end
	elsif q == 'look'
		puts desc
		flush = false
	elsif q[0..3] == 'raw '
		# raw mode
		engine.push_string(q[4..-1])
	else
		puts '>> invalid command'
		flush = false
	end
	puts

	puts "ERROR: Intcode computer has crashed!" if engine.crash || engine.halt

end


