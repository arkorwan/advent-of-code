input = IO.foreach('../data/21.txt').map(&:strip)

i0 = input.index{ _1.include?('S')}
j0 = input[i0].index('S')

def add(input, m, i, j, d)
  if i >= 0 && i < m.size && j >= 0 && j < m[0].size && input[i][j] != '#' && m[i][j] > d
    m[i][j] = d
    [i, j]
  else
    nil
  end
end

def build_m(input, i0, j0)
  m = Array.new(input.size).map{Array.new(input[0].size, 10000)}
  m[i0][j0] = 0
  queue = [[i0, j0]]
  while not queue.empty?
    i, j = queue.pop
    d = m[i][j]
    xs = []
    xs << add(input, m, i-1, j, d+1)
    xs << add(input, m, i+1, j, d+1)
    xs << add(input, m, i, j-1, d+1)
    xs << add(input, m, i, j+1, d+1)
    xs.each{|t| queue.unshift(t) if t}
  end
  m
end

m_middle = build_m(input, i0, j0)

p m_middle.map{|x| x.count{_1 % 2 == 0 && _1 <= 64}}.sum

double_input = input.map{_1*2}*2

# part 2

w = double_input.size

# Notice the rows and columns with the starting 'S' are all empty.
# We rearrange the map, shifting the starting 'S' to the top-left corner,
# and pad one empty row and one empty column.
# This let us approach the map internals from either of the 4 corners.

def shifted_input(input, dx, dy)
  (input[dx..-1] + input[0...dx]).map{|line|
    line[dy..-1] + line[0...dy] + "."
  } + ["."*(input[0].size+1)]
end
input_shifted = shifted_input(double_input, i0, j0)

m_se = build_m(input_shifted, 0, 0)
m_sw = build_m(input_shifted, 0, w)
m_ne = build_m(input_shifted, w, 0)
m_nw = build_m(input_shifted, w, w)

t = 0
k = 26501365

[m_se, m_sw, m_ne, m_nw].each{|m|
  1.upto(w-1){|i|
    1.upto(w-1){|j|
      d = m[i][j]
      if d < 10000 && d % 2 == 1
        q = (k-d)/w
        t += (q+1)*(q+2)/2
      end
    } 
  }
}

z = k/w
t += 2*(2*z+1)*(k+1) - 2*w*z*(z+1)
p t
