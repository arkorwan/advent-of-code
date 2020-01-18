class IntCode

	@a

	attr_accessor :pc, :counter, :inputs, :base, :halt, :crash, :wait_for_input, :op_limit

	def initialize(a)
		@a = a.clone
		@pc = 0
		@counter = 0
		@halt = false
		@crash = false
		@wait_for_input = false
		@inputs = []
		@base = 0
		@op_limit = 1000000
	end

	def clone
		b = IntCode.new(@a)
		b.pc = @pc
		b.counter = @counter
		b.halt = @halt
		b.crash = @crash
		b.wait_for_input = @wait_for_input
		b.inputs = @inputs.clone
		b.base = @base
		b.op_limit = op_limit
		b
	end

	# input methods

	# insert 1 input value
	def push(input)
		@inputs << input
		@wait_for_input = false
	end

	# insert multiple input values
	def push_all(inputs)
		@inputs.push(*inputs)
		@wait_for_input = false
	end

	# insert the given string, by converting it into list of ascii codes, followed by newline (10)
	def push_string(s)
		puts "intcode:> #{s}"
		push_all(s.each_byte.to_a)
		@inputs << 10
	end

	# run until more input is required (or the machine is halted) 
	def run
		outputs = []
		@counter = 0
		until @crash || @halt || @wait_for_input
			res = step(false)
			outputs << res if res
		end
		outputs
	end

	# run, and interpreted the result as ascii characters
	def run_string
		run.map{|c| c < 128 ? c.chr : c.to_s}.join
	end

	private

	# run until an output is produced, an input is required and there's none, or the machine is halted.  

	def step(reset_counter = true)
		@counter = 0 if reset_counter
		res = nil
		until res || @halt || @crash
			case memread(@pc) % 100
			when 1
				write(3, read(1) + read(2))
				@pc+=4
			when 2
				write(3, read(1) * read(2))
				@pc+=4
			when 3
				if @inputs.empty?
					@wait_for_input = true
					break
				end
				write(1, @inputs.shift)
				@pc+=2
			when 4
				res = read(1)
				@pc+=2
			when 5
				if read(1) == 0
					@pc+=3
				else
					@pc=read(2)
				end
			when 6
				if read(1) != 0
					@pc+=3
				else
					@pc=read(2)
				end
			when 7
				write(3, read(1) < read(2) ? 1 : 0)
				@pc += 4
			when 8
				write(3, read(1) == read(2) ? 1 : 0)
				@pc += 4
			when 9
				@base += read(1)
				@pc += 2
			when 99
				@halt = true
			end

			@counter += 1
			
			if @counter >= @op_limit
				puts "Too many operations. Will this ever end? I better bail out!"
				@crash = true
			end
		end

		res
	end
	
	def memread(i)
		@a[i] || 0
	end

	def read(position)
		raw = memread(@pc+position)
		case memread(@pc) / (10**(position + 1)) % 10
		when 0 then memread(raw)
		when 1 then raw
		when 2 then memread(raw+@base)
		end
	end

	def write(position, value)
		raw = memread(@pc+position)
		case memread(@pc) / (10**(position + 1)) % 10
		when 0 then @a[raw] = value
		when 2 then @a[raw + @base] = value
		end
	end

	
end