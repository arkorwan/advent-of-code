import strutils, sequtils, tables, math, re

let
    input = readFile("../data/08.txt").strip.splitLines
    ops = input[0]

var
    left = initTable[string, string]()
    right = initTable[string, string]()
for line in input[2..^1]:
    let parts = line.split(re"[\s,\(\)]")
    left[parts[0]] = parts[3]
    right[parts[0]] = parts[5]

proc findNode(start, target: string): int =
    var node = start
    var steps = 0
    while not node.endsWith(target):
        let d = ops[steps mod ops.len]
        steps += 1
        node = if(d == 'L'): left[node] else: right[node]
    steps

# part 1
echo findNode("AAA", "ZZZ")

# part 2
let starts = left.keys.toSeq.filterIt(it.endsWith("A"))
echo starts.mapIt(findNode(it, "Z").uint64).foldl(lcm(a, b))
