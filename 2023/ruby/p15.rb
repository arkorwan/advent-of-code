input = IO.read('../data/15.txt').strip.split(',')

def h(s) = s.each_char.reduce(0){((_1 + _2.ord) * 17)} % 256

# part 1
p input.map{h(_1)}.sum

# part 2
box = Array.new(256).map{[]}
input.each{|op|
  if op[-1] == '-'
    key = op[0..-2]
    hsh = h(key)
    i = box[hsh].index{|x, y| x == key}
    box[hsh].delete_at(i) if i
  else
    key, value = op.split('=')
    hsh = h(key)
    i = box[hsh].index{|x, y| x == key} || box[hsh].size
    box[hsh][i] = [key, value.to_i]
  end
}

p box.each_with_index.map{|b, i|
  b.each_with_index.map{|a, j| a[1] * (j+1)}.sum * (i+1)
}.sum
