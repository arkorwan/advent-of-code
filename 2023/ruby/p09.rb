input = IO.foreach('../data/09.txt').map{|line| 
  line.split.map(&:to_i)
}

def f(seq)
  s = seq[-1]
  until seq.all?{_1 == 0}
    seq = seq[1..-1].zip(seq[0..-2]).map{|x, y| x - y}
    s += seq[-1]
  end
  s
end

# part 1
p input.map{f(_1)}.sum

# part 2
p input.map{f(_1.reverse)}.sum
