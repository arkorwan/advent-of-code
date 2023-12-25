input = IO.read('../data/19.txt').strip.split("\n\n")

rules = {}
input[0].split("\n").each{|rule|
  i = rule.index('{')
  name = rule[0...i]
  conditions = rule[i+1..-2].split(",").map{|con|
    sp = con.split(":")
    if sp.size == 1
      [0, :>, 0 , sp[0]]
    else
      j = "xmas".index(sp[0][0])
      t = sp[0][2..-1].to_i
      if sp[0][1] == '<'
        [j, :<, t, sp[1]] 
      else
        [j, :>, t, sp[1]] 
      end
    end
  }
  rules[name] = conditions

}

# part 1
parts = input[1].split("\n").map{|line| line[1..-2].split(",").map{ _1.split("=")[1].to_i}}
p parts.map{|q|
  label = "in"
  until label == "A" || label == "R"
    nxt = rules[label].find{ |con|
      q[con[0]].send(con[1], con[2])
    }
    label = nxt[3]
  end
  label == "A" ? q.sum : 0
}.sum

# part 2
def partition_lt(r, v)
  if v <= r[0]
    [nil, r]
  elsif v <= r[1]
    [[r[0], v-1], [v, r[1]]]
  else
    [r, nil]
  end
end

def f(rules, label, i, r)

  return r.map{|x, y| y-x+1}.reduce(:*) if label == 'A'
  return 0 if label == 'R'
  
  con = rules[label][i]
  s = 0
  r0 = r[con[0]]
  r1 = r2 = nil
  if con[1] == :<
    r1, r2 = partition_lt(r0, con[2])
  else
    r2, r1 = partition_lt(r0, con[2]+1)
  end
  
  if r1
    r[con[0]] = r1
    s += f(rules, con[3], 0, r)
    r[con[0]] = r0
  end

  if r2
    r[con[0]] = r2
    s += f(rules, label, i+1, r)
    r[con[0]] = r0
  end
  s
end

r = [[1, 4000], [1, 4000], [1, 4000], [1, 4000]]
p f(rules, "in", 0, r)
