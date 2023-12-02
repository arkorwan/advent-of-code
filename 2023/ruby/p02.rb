input = IO.foreach('../data/02.txt').map(&:strip)

games = input.map{|line| 
  parts = line.split(/[:;]/)
  id = parts[0].split(' ')[1].to_i
  res = parts[1..-1].map{|x| 
    comps = x.strip.split(/[, ]+/)
    h = Hash[*comps.reverse]
    h.default = "0"
    [h["red"].to_i, h["green"].to_i, h["blue"].to_i]
  }
  [id, res]
}

# part 1
p games.map{|id, parts|
  valid = parts.all?{|r,g,b| r <= 12 && g <= 13 && b <= 14}
  valid ? id : 0
}.sum

# part 2
p games.map{|id, parts|
  r = parts.map{|c| c[0]}.max
  g = parts.map{|c| c[1]}.max
  b = parts.map{|c| c[2]}.max
  r*g*b
}.sum
