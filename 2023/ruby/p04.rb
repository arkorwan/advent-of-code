input = IO.foreach('../data/04.txt').map(&:strip)
cards = [1]*input.size
score = input.each_with_index.map{|line,i|
  parts = line.split(/[:|]/)
  a = parts[1].split.map(&:to_i)
  b = parts[2].split.map(&:to_i)
  c = b.count{|n| a.include?(n)}
  (i+1).upto(i+c){|j| cards[j] += cards[i] }
  (2**c)/2
}.sum

puts score, cards.sum
