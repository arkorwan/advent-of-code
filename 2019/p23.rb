require './intcode.rb'

a = IO.read("in23.txt").split(",").map(&:to_i)


engines = 50.times.map{|i| 
	engine = IntCode.new(a)
	engine.push(i)
	engine.run
	engine
}

bus = Array.new(50).map{Array.new}
nat_msg = nil

delivered_y = nil

found = false

until found
	idle = true
	50.times{|i|
		e = engines[i]
		input = bus[i]
		if input.empty?
			e.push(-1)
		else
			idle = false
			e.push_all(input.shift)
		end
		msgs = e.run.each_slice(3).to_a
		msgs.each{|msg| 
			if msg[0] == 255
				nat_msg = msg
				puts "NAT receives #{msg.inspect}"
			else
				bus[msg[0]].push(msg[1], msg[2])
			end
		}
			
	}
	if idle && nat_msg
		bus[0].push(nat_msg[1], nat_msg[2])
		puts "NAT sends #{nat_msg.inspect}"
		if nat_msg[2] == delivered_y
			found = true
			p nat_msg
		end
		delivered_y = nat_msg[2]
	end
	
end