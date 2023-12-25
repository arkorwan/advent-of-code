input = IO.foreach('../data/18.txt').map(&:strip)

def go(ops)
  
  hs = {}
  vs = {}
  x = 0
  y = 0
  minx = 0
  maxx = 0
  miny = 0
  maxy = 0
  ops.each{|a, b|
    case a
    when 'R'
      hs[y] ||= []
      hs[y] << [x, x+b]
      x += b
    when 'L'
      hs[y] ||= []
      hs[y] << [x-b, x]
      x -= b
    when 'D'
      vs[x] ||= []
      vs[x] << [y, y+b]
      y += b
    when 'U'
      vs[x] ||= []
      vs[x] << [y-b, y]
      y -= b
    end
    minx = x if x < minx
    maxx = x if x > maxx
    miny = y if y < miny
    maxy = y if y > maxy
  }

  s = 0
  prev_y = nil
  ranges = []
  insides = 0
  hs.sort.each{|y, ls|
    s += (y-prev_y-1)*insides if prev_y
    t = insides
    ls.sort.each{|u, v|
      i = ranges.index{_1[0] <= u && _1[1] >= v}
      if i
        u0, v0 = ranges[i]
        if u0 == u && v0 == v
          ranges.delete_at(i)
          insides -= v-u+1
        elsif u0 == u
          ranges[i][0] = v
          insides -= v-u
        elsif v0 == v
          ranges[i][1] = u
          insides -= v-u
        else
          ranges[i][0] = v
          ranges.insert(i, [u0, u])
          insides -= v-u-1
        end
      else
        i = ranges.rindex{_1[1] <= u}
        j = ranges.index{_1[0] >= v}
        #p ["ij", u, v, i, j]
        if i != nil && j != nil
          if ranges[i][1] == u && ranges[j][0] == v
            ranges[i][1] = ranges[j][1]
            ranges.delete_at(j)
            t += v-u-1
            insides += v-u-1
          elsif ranges[i][1] == u
            ranges[i][1] = v
            t += v-u
            insides += v-u
          elsif ranges[j][0] == v
            ranges[j][0] = u
            t += v-u
            insides += v-u
          else
            ranges.insert(j, [u, v])
            t += v-u+1
            insides += v-u+1
          end
        elsif i
          if ranges[i][1] == u
            ranges[i][1] = v
            t += v-u
            insides += v-u
          else
            ranges << [u, v]
            t += v-u+1
            insides += v-u+1
          end
        elsif j
          if ranges[j][0] == v
            ranges[j][0] = u
            t += v-u
            insides += v-u
          else
            ranges.unshift([u, v])
            t += v-u+1
            insides += v-u+1
          end
        else
          ranges << [u, v]
          t += v-u+1
          insides += v-u+1
        end
      end

    }
    s += t
    prev_y = y
  }
  s
end

# part 1
ops1 = input.map{|line| 
  a,b,c = line.split(' ')
  [a, b.to_i, c[1..-2]]
}
p go(ops1)

# part 2
ops2 = input.map{|line| 
  a,b,c = line.split(' ')
  ["RDLU"[c[7].to_i], c[2..6].to_i(16)]
}
p go(ops2)
