input = IO.foreach('../data/07.txt').map(&:split)

@partitions = [ [5], [1, 4], [2, 3], [1, 1, 3], [1, 2, 2], [1, 1, 1, 2], [1, 1, 1, 1, 1] ]

def get_type(hands, joker)
  hands = hands.filter{_1 != joker} if joker
  sorted_counter = hands.tally.values.sort
  if sorted_counter.empty?
    sorted_counter = [5]
  else 
    sorted_counter[-1] += 5-hands.size
  end
  @partitions.index(sorted_counter)
end

def calc(input, card_values, joker)
  input.map{|hands_str, bid|
    hands = hands_str.chars.map{card_values[_1]}
    t = get_type(hands, joker)
    [t, hands, bid.to_i]
  }.sort.reverse.each_with_index.map{|x, order|
    x[2] * (order + 1)
  }.sum
end

# part 1
p calc(input, "AKQJT98765432".chars.each_with_index.to_h, joker=nil)

# part 2
p calc(input, "AKQT98765432J".chars.each_with_index.to_h, joker=12)
