input = IO.foreach('../data/24.txt').map(&:strip)
l1 = 200000000000000
l2 = 400000000000000

hails = input.map{|line|
  sp = line.split(" ")
  sp.delete_at(3)
  h = sp.map(&:to_i)
  x,y,z,dx,dy,dz = h
  # formatted as y = mx + c
  m = Rational(dy, dx)
  c = y - m * x  
  [h, m, c]
}

# part 1

def intersect(h1, h2)
  d = h1[1] - h2[1]
  return nil if d == 0 # no single intersection point
  x = (h2[2] - h1[2])/d
  y = h1[1]*(h2[2] - h1[2])/d + h1[2]
  [x, y]
end

s = 0
hails.size.times{|i|
  h1 = hails[i]
  (i+1).upto(hails.size-1){|j|
    h2 = hails[j]
    pt = intersect(h1, h2)
    next if not pt
    x,y = pt
    if x >= l1 && x <= l2 && y >= l1 && y <= l2
      g1 = h1[0][1] != 0 ? (x - h1[0][0])/h1[0][3] >= 0 : (y - h1[0][1])/h1[0][4] >= 0
      g2 = h2[0][1] != 0 ? (x - h2[0][0])/h2[0][3] >= 0 : (y - h2[0][1])/h2[0][4] >= 0
      s += 1 if g1 && g2
    end 
  }
}
p s

# part 2

# input is array of [velocity, position] along one axis
def find_velocity(vps, min_v, max_v)
  grouped = vps.group_by{_1[0]}.map{|k, vs| [k, vs.map{_1[1]}.sort]}
  vrs = grouped.filter{_2.size > 2}.map{|v, ps|
    diffs = []
    1.upto(ps.size-1){|i| diffs << ps[i] - ps[i-1]}
    r = diffs.reduce(:gcd)
    [v, r]
  }
  min_v.upto(max_v).filter{|v0|
    vrs.all?{|vh, r| v0 != vh && r % (v0-vh) == 0}
  }
end

def prime_power_decomposition(n)
  sieve = Array.new(n+1).map{[]}
  2.upto(n){|i|
    if sieve[i].empty?
      i.step(n,i){|j| sieve[j] << i}
      ii = i*i
      while ii <= n
        ii.step(n, ii){|j| sieve[j][-1] = ii}
        ii *= i
      end
    end
  }
  sieve
end

def mod_inv(a, m)
  raise "NO INVERSE - #{a} and #{m} not coprime" unless a.gcd(m) == 1
  return m if m == 1
  m0, inv, x0 = m, 1, 0
  while a > 1
    inv -= (a / m) * x0
    a, m = m, a % m
    inv, x0 = x0, inv
  end
  inv += m0 if inv < 0
  inv
end

def crt_op(op1, op2)
  raise "non coprime remainder" if op1[0].gcd(op2[0]) != 1
  mx = op1[0] * op2[0]
  v = op2[0] * op1[1] * mod_inv(op2[0], op1[0]) + op1[0] * op2[1] * mod_inv(op1[0], op2[0])
  [mx, v % mx]
end

def find_position(vps, v0, pf)
  mods = {}
  vps.each{|v, pos|
    mod = (v - v0).abs
    pf[mod].each{|pe|
      rem = pos % pe
      raise "incompatible remainder" if mods[pe] && mods[pe] != rem
      mods[pe] = rem 
    }
  }
  unneeded_keys = mods.keys.filter{|k| mods.keys.any?{|x| x != k && x % k == 0 }}
  unneeded_keys.each{|k| mods.delete(k)}
  res = mods.to_a.reduce{|x, y| crt_op(x, y)}
  if res[1] < res[0]-res[1]
    res[1]
  else
    -(res[0]-res[1])
  end
end

hails_x = hails.map{|h,z| [h[3], h[0]]}
v0x = find_velocity(hails_x, -1000, 1000)[0]
pf = prime_power_decomposition(1000)
p0x = find_position(hails_x, v0x, pf)

coords = hails.map{|q|
  h = q[0]
  t = (h[0]-p0x).abs / (h[3]-v0x).abs
  px = h[0] + t*h[3]
  py = h[1] + t*h[4]
  pz = h[2] + t*h[5]
  [t, px, py, pz]
}

v0y = (coords[1][2] - coords[0][2]) / (coords[1][0] - coords[0][0])
v0z = (coords[1][3] - coords[0][3]) / (coords[1][0] - coords[0][0])
p0y = coords[0][2] - coords[0][0]*v0y
p0z = coords[0][3] - coords[0][0]*v0z

p p0x + p0y + p0z
