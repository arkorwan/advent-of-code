input = IO.foreach('../data/01.txt').map(&:strip)

digits = "0123456789".chars.each_with_index.to_a
words = digits + ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"].each_with_index.to_a

def find_first(s, targets)
  targets
    .map{|w, value| [s.index(w), value]}
    .filter{_1[0]}
    .min[1]
end

def find_last(s, targets)
  targets
    .map{|w, value| [s.rindex(w), value]}
    .filter{_1[0]}
    .max[1]
end

# part 1
p input.map{find_first(_1, digits)}.sum * 10 + input.map{find_last(_1, digits)}.sum

# part 2
p input.map{find_first(_1, words)}.sum * 10 + input.map{find_last(_1, words)}.sum
