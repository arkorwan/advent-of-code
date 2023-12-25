input = IO.foreach('../data/12.txt').map(&:strip).map{|line|
  field, numstr = line.split
  num = numstr.split(',').map(&:to_i)
  [field, num]  
}

def consume(field, i, rem, cache = {})
  key = [i, field[i], rem]
  
  cached = cache[key]
  return cached if cached
  return rem.empty? ? 1 : 0 if i >= field.size
  return cache[key] = (field[i..-1].include?('#') ? 0 : 1) if rem.empty?
  
  return cache[key] = consume(field, i+1, rem, cache) if field[i] == '.'

  if field[i] == '#'
    a = rem[0]
    (i+1).upto(i+a-1){|j|
      return cache[key] = 0 if field[j] == '.' || j >= field.size
    }
    return cache[key] = 0 if field[i+a] == '#'
    return cache[key] = consume(field, i+a+1, rem[1..-1], cache)
  end

  field[i] = '.'
  c1 = consume(field, i, rem, cache)
  field[i] = '#'
  c2 = consume(field, i, rem, cache)
  field[i] = '?'
  return cache[key] = c1 + c2

end

# part 1
p input.map{|field, num| consume(field, 0, num)}.sum

# part 2
p input.map{|field, num| consume(([field]*5).join('?'), 0, num*5)}.sum
