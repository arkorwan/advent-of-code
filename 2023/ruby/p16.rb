@input = IO.foreach('../data/16.txt').map(&:strip)

@h = @input.size
@w = @input[0].size

@up = 1
@left = 2
@down = 4
@right = 8

@dx = {@up => -1, @down => 1, @left => 0, @right => 0}
@dy = {@up => 0, @down => 0, @left => -1, @right => 1}
@diag = {@up => @left, @left => @up, @down => @right, @right => @down}
@antidiag = {@up => @right, @right => @up, @down => @left, @left => @down}

def f(x0, y0, d0)
  en = Array.new(@h).map{[0]*@w}

  stack = [[x0, y0, d0]]
  until stack.empty?
    x,y,d = stack.pop
    next if x < 0 || y < 0 || x >= @h || y >= @w
    if en[x][y] & d == 0
      en[x][y] |= d
      if @input[x][y] == '.' || (@input[x][y] == '-' && @dy[d] != 0) || (@input[x][y] == '|' && @dx[d] != 0)
        nx = x + @dx[d]
        ny = y + @dy[d]
        stack << [nx, ny, d]
      elsif @input[x][y] == '/'
        nd = @antidiag[d]
        nx = x + @dx[nd]
        ny = y + @dy[nd]
        stack << [nx, ny, nd]
      elsif @input[x][y] == '\\'
        nd = @diag[d]
        nx = x + @dx[nd]
        ny = y + @dy[nd]
        stack << [nx, ny, nd]
      elsif @input[x][y] == '|'
        stack << [x-1, y, @up]
        stack << [x+1, y, @down]
      else
        stack << [x, y-1, @left]
        stack << [x, y+1, @right]
      end
    end
  end

  en.map{|row|
    row.count{_1 != 0}
  }.sum
end

# part 1
p f(0, 0, @right)

# part 2
max_west = @h.times.map{ f(_1, 0, @right) }.max
max_east = @h.times.map{ f(_1, @w-1, @left) }.max
max_north = @w.size.times.map{ f(0, _1, @down) }.max
max_south = @w.size.times.map{ f(@h-1, _1, @up) }.max

p [max_west, max_east, max_north, max_south].max
