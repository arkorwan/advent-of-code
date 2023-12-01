input = IO.foreach('../data/01.txt').map(&:strip)

digits = "0123456789".chars.each_with_index.to_a
words = digits + ["zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"].each_with_index.to_a

def find_first(s, targets)
  targets
    .map{|w, value| [s.index(w), value]}
    .select{|i, value| i != nil}
    .min[1]
end

def find_last(s, targets)
  targets
    .map{|w, value| [s.rindex(w), value]}
    .select{|i, value| i != nil}
    .max[1]
end

# part 1
p input.map{|s| find_first(s, digits)}.sum * 10 + input.map{|s| find_last(s, digits)}.sum

# part 2
p input.map{|s| find_first(s, words)}.sum * 10 + input.map{|s| find_last(s, words)}.sum
