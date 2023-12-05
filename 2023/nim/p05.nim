import strutils, sequtils, algorithm, sugar

let
    input = readFile("../data/05.txt").strip.splitLines
    seeds = input[0].split[1..^1].mapIt(it.strip.parseInt)

func normalizeRange(ranges: seq[(int, int, int)]): auto =
    var res: seq[(int, int)] = @[]
    var prev = -1
    for item in ranges.sorted:
        if prev >= 0 and prev != item[0]:
            res.add((prev, 0))
        res.add((item[0], item[2]))
        prev = item[1]
    res.add((prev, 0))
    res

func parseMap(input: seq[string]): auto =
    var maps: seq[seq[(int, int)]] = @[]
    var ranges: seq[(int, int, int)] = @[]
    for line in input[3..^1]:
        if not line.isEmptyOrWhitespace:
            if line[^1] == ':':
                maps.add(normalizeRange(ranges))
                ranges = @[]
            else:
                let
                    nums = line.split.mapIt(it.parseInt)
                    x = nums[0]
                    y = nums[1]
                    z = nums[2]
                ranges.add (y, y+z, x-y)
    maps.add(normalizeRange(ranges))
    maps

func findMapIndex(mappings: seq[(int, int)], target: int): int =
    for i, mp in mappings:
        if mp[0] > target:
            return i-1
    return mappings.len-1

func convert(source: int, mappings: seq[(int, int)]): int =
    let i = findMapIndex(mappings, source)
    source + mappings[i][1]

func convertRange(srcRanges: seq[(int, int)], mappings: seq[(int, int)]): seq[(
        int, int)] =
    var res: seq[(int, int)] = @[]
    for src in srcRanges:
        let
            (fro, til) = src
            i = findMapIndex(mappings, fro)
            j = findMapIndex(mappings, til-1)
        var diff = mappings[i][1]
        if i == j:
            res.add((fro + diff, til + diff))
        else:
            res.add((fro + diff, mappings[i+1][0] + diff))
            for k in (i+1..j-1):
                diff = mappings[k][1]
                res.add((mappings[k][0] + diff, mappings[k+1][0] + diff))
            diff = mappings[j][1]
            res.add((mappings[j][0] + diff, til + diff))
    res

let maps = parseMap(input)

# part 1
echo seeds.map(seed => maps.foldl(convert(a, b), seed)).min

# part 2
var seedRanges: seq[(int, int)] = @[]
for i in (0..(seeds.len div 2 - 1)):
    let x = seeds[2*i]
    let y = seeds[2*i+1]
    seedRanges.add((x, x+y))
echo maps.foldl(convertRange(a, b), seedRanges).min[0]
