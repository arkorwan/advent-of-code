input = IO.foreach('../data/05.txt').map(&:strip)

seeds = input[0].split[1..-1].map(&:to_i)

# sort and fill the gaps with 0-diff ranges
def normalize_range(ranges)
  res = []
  prev = nil
  ranges.sort.each{|from, to, diff|
    res << [prev, 0] if prev && from != prev
    res << [from, diff]
    prev = to
  }
  res << [prev, 0]
end

def parse_map(input)
  maps = []
  ranges = []
  input[3..-1].each{|line|
    next if line.empty?
    if line[-1] == ':'
      maps << normalize_range(ranges)
      ranges = []
    else
      x,y,z = line.split.map(&:to_i)
      ranges << [y, y+z, x-y] # [src start, src end, diff from src to dest]
    end
  }
  maps << normalize_range(ranges)
end

maps = parse_map(input)

def find_map_index(mappings, target)
  i = mappings.bsearch_index{|x| x[0] > target} || mappings.size
  i-1
end

def convert(source, mappings)
  i = find_map_index(mappings, source)
  source + mappings[i][1]
end

def convert_range(src_ranges, mappings)
  src_ranges.flat_map{|from, til|
    i = find_map_index(mappings, from)
    j = find_map_index(mappings, til-1)
    if i == j
      diff = mappings[i][1]
      [[from + diff, til + diff]]
    else
      nxt = []
      diff = mappings[i][1]
      nxt << [from + diff, mappings[i+1][0] + diff]
      (i+1).upto(j-1){|k|
        diff = mappings[k][1]
        nxt << [mappings[k][0] + diff, mappings[k+1][0] + diff]
      }
      diff = mappings[j][1]
      nxt << [mappings[j][0] + diff, til + diff]
      nxt
    end
  }
end

# part 1
p seeds.map{|seed| maps.reduce(seed){|src,mp| convert(src, mp)}}.min

# part 2
seed_ranges = seeds.each_slice(2).map{|x, y| [x, x + y]}
p maps.reduce(seed_ranges){|src, mp| convert_range(src, mp)}.min[0]
