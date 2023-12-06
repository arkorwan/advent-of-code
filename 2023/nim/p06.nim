import strutils, sequtils, math

let
    input = readFile("../data/06.txt").strip.splitLines
    time = input[0].splitWhitespace[1..^1]
    distance = input[1].splitWhitespace[1..^1]

func f(t: uint64, d: uint64): int =
    let
        x = sqrt((t*t - 4*d).float)
        a = ((t.float-x)/2).floor.int + 1
        b = ((t.float+x)/2).ceil.int - 1
    b-a+1

# part 1
echo (0..3).mapIt(f(time[it].parseUInt, distance[it].parseUInt)).foldl(a*b)

# part 2
echo f(time.join.parseUInt, distance.join.parseUint)
