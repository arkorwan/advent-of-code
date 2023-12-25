input = IO.foreach('../data/06.txt').map(&:strip)

time = input[0].split[1..-1]
distance = input[1].split[1..-1]

def f(t, d)
  x = (t*t - 4*d)**0.5
  a = ((t-x)/2).floor + 1
  b = ((t+x)/2).ceil - 1
  b-a+1
end

# part 1
p 4.times.map{|i|
  f(time[i].to_i, distance[i].to_i)
}.reduce(:*)

# part 2
p f(time.join.to_i, distance.join.to_i)
