input = IO.foreach('../data/14.txt').map(&:strip)

mp = input.map(&:chars)

def score(mp) = mp.each_with_index.map{|row, i| row.count('O') * (mp.size-i)}.sum

def rollup!(mp)
  mp.size.times{|i| mp[0].size.times{|j|
    if mp[i][j] == 'O'
      r = i
      r -= 1 while r >= 1 && mp[r-1][j] == '.'
      mp[i][j] = '.'
      mp[r][j] = 'O'
    end
  }}
end

# part 1
rollup!(mp)
p score(mp)

# part 2
prevs = []
prev_scores = []
s = score(mp)
i = 0
j = nil
until j
  prevs << mp.map(&:clone)
  prev_scores << s
  4.times{
    rollup!(mp)
    mp = mp.reverse.transpose # rotate CW
  }
  
  s = score(mp)
  i += 1
  j = prevs.size.times.find{ prev_scores[_1] == s && prevs[_1] == mp }
end

p prev_scores[j + (1000000000-j) % (i-j)]
