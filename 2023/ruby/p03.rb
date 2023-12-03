input = IO.foreach('../data/03.txt').map(&:strip)

h = input.size
w = input[0].size

@input = ['.'*(w+2)] + input.map{|line| ".#{line}."} + ['.'*(w+2)]

def is_digit(c)
  c >= '0' && c <= '9'
end

# overall state
@parts_sum = 0
@all_gears = {}

# state variables
@current_num = 0
@is_valid_part = false
@current_gears = []

def check_adjacent(adj)
  adj.each{|y, x|
    c = @input[y][x] 
    if c != '.' && !is_digit(c)
      @is_valid_part = true
      @current_gears << [y, x] if @input[y][x] == '*'
    end
  }
end

def reset()
  if @current_num > 0 && @is_valid_part
    @parts_sum += @current_num
    @current_gears.each{|y, x|
      @all_gears[[y, x]] ||= []
      @all_gears[[y, x]] << @current_num
    }
  end
  @current_num = 0
  @is_valid_part = false
  @current_gears = []
end
 
1.upto(h){|j|
  1.upto(w){|i|
    c = @input[j][i]
    if @current_num > 0
      if is_digit(c)
        @current_num = @current_num * 10 + c.to_i
        check_adjacent([[j-1, i+1], [j+1, i+1]])
      else
        check_adjacent([[j, i]])
        reset()
      end
    elsif is_digit(c)
      @current_num = c.to_i
      check_adjacent([[j-1, i-1], [j-1, i], [j-1, i+1], [j, i-1], [j+1, i-1], [j+1, i], [j+1, i+1]])
    end
  }
  reset()
}

# part 1
p @parts_sum

# part 2
p @all_gears.values.select{|vs| vs.size == 2}.map{|vs| vs[0]*vs[1]}.sum
