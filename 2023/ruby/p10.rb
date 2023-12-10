require 'set'

input = IO.foreach('../data/10.txt').map(&:strip)

def find_S(input)
  input.each_with_index{|line, i|
    j = line.index('S')
    return [i, j] if j
  }
  [-1, -1]
end

def replace_S!(input, c)
  x0, y0 = c
  mask = 0
  mask += "-FL".include?(input[x0-1][y0]) ? 1 : 0
  mask += "-7J".include?(input[x0+1][y0]) ? 2 : 0
  mask += "|F7".include?(input[x0][y0-1]) ? 4 : 0
  mask += "|LJ".include?(input[x0][y0+1]) ? 8 : 0

  input[x0][y0] = case mask
  when 3 then '-'
  when 5 then 'J'
  when 9 then '7'
  when 6 then 'L'
  when 10 then 'F'
  when 12 then '|'
  end
end

def build_cycle(input, c)
  cycle = Set.new
  prev_c = nil
  until cycle.include? c  
    cycle << c
    x, y = c
    cands = case input[x][y]
    when "-" then [[x, y-1], [x, y+1]]
    when "|" then [[x-1, y], [x+1, y]]
    when "L" then [[x-1, y], [x, y+1]]
    when "J" then [[x-1, y], [x, y-1]]
    when "F" then [[x+1, y], [x, y+1]]
    when "7" then [[x+1, y], [x, y-1]]
    end
    prev_c, c = c, cands.find{|z| z != prev_c}
  end
  cycle
end

def count_area(input, cycle)
  area = 0
  input.each_with_index{|line, x|
    inside = false
    section_start = nil
    line.chars.each_with_index{|q, y|
      if cycle.include? [x, y]
        case q
        when '-'
          # do nothing
        when '|'
          inside = !inside
        when '7'
          inside = !inside if section_start == 'L'
          section_start = nil
        when 'J'
          inside = !inside if section_start == 'F'
          section_start = nil
        else
          section_start = q
        end
      elsif inside
        area += 1
      end
    }
  }
  area
end

starting_S = find_S(input)
replace_S!(input, starting_S)
cycle = build_cycle(input, starting_S)

# part 1
p cycle.size / 2

# part 2
p count_area(input, cycle)
