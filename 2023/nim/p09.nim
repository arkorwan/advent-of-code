import strutils, sequtils, sugar, math, algorithm

let input = readFile("../data/09.txt").strip.splitLines.map(line =>
    line.splitWhitespace.mapIt(it.parseInt)
)

func f(xs: seq[int]): int =
    var s = xs[^1]
    var ys = xs
    while not ys.allIt(it == 0):
        ys = ys[1..^1].zip(ys[0..^2]).mapIt(it[0] - it[1])
        s += ys[^1]
    s

# part 1
echo input.map(f).sum

# part 2
echo input.mapIt(f(it.reversed)).sum
