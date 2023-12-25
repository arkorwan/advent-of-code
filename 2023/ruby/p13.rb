input = IO.read('../data/13.txt').split("\n\n")

horizontals = input.map{|x| x.strip.split.map{|line| line.chars}}
verticals = horizontals.map(&:transpose)

# count the number of diffs assuming the reflection is at row i 
def diffs_at(mp, i)
  a = mp[0...i].reverse
  b = mp[i..-1]
  zipped = a.size <= b.size ? a.zip(b) : b.zip(a)
  zipped.map{|r1, r2| r1.zip(r2).count{_1 != _2}}.sum
end

h_diffs = horizontals.map{|mp|
  a = [nil]
  1.upto(mp.size-1).each{|i| a << diffs_at(mp, i)}
  a
}
v_diffs = verticals.map{|mp|
  a = [nil]
  1.upto(mp.size-1).each{|i| a << diffs_at(mp, i)}
  a
}

def score(n, hs, vs, target)
  h_score = n.times.map{|i| hs[i].index(target) || 0 }.sum
  v_score = n.times.map{|i| vs[i].index(target) || 0 }.sum
  h_score * 100 + v_score
end

# part 1
p score(input.size, h_diffs, v_diffs, 0)

# part 2
p score(input.size, h_diffs, v_diffs, 1)
