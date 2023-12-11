require 'set'

input = IO.foreach('../data/11.txt').map(&:strip)

h1 = input.size
w1 = input[0].size

empty_rows = Set.new(h1.times.filter{|i| !input[i].include?('#')})
empty_cols = Set.new(w1.times.filter{|j| !input.map{|line| line[j]}.any?{|c| c == '#'}})

galaxies = []
i_offset = 0
h1.times{|i|
  i_offset += 1 if empty_rows.include?(i)
  j_offset = 0
  w1.times{|j|
    j_offset += 1 if empty_cols.include?(j)
    galaxies << [i, i_offset, j, j_offset] if input[i][j] == '#'
  }
}

def all_pairs_distance(galaxies, expansion)
  m = expansion - 1
  galaxies.combination(2).map{|g1, g2|
    x1, xo1, y1, yo1 = g1
    x2, xo2, y2, yo2 = g2
    (x1-x2+(xo1-xo2)*m).abs + (y1-y2+(yo1-yo2)*m).abs
  }.sum
end

# part 1
p all_pairs_distance(galaxies, 2)

# part 2
p all_pairs_distance(galaxies, 1000000)
