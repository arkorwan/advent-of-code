import strutils, sequtils

const
    digits = "0123456789".pairs.toSeq.mapIt(($it[1], it[0]))
    words = digits & @[("zero", 0), ("one", 1), ("two", 2), ("three", 3), (
            "four", 4), ("five", 5), ("six", 6), ("seven", 7), ("eight", 8), (
            "nine", 9)]

func findFirst(s: string, targets: seq[(string, int)]): int =
    targets.mapIt((s.find(it[0]), it[1]))
        .filterIt(it[0] >= 0)
        .min[1]

func findLast(s: string, targets: seq[(string, int)]): int =
    targets.mapIt((s.rfind(it[0]), it[1]))
        .filterIt(it[0] >= 0)
        .max[1]

let input = readFile("../data/01.txt").splitLines

# part 1
echo input.mapIt(findFirst(it, digits)*10 + findLast(it, digits)).foldl(a+b)

# part 2
echo input.mapIt(findFirst(it, words)*10 + findLast(it, words)).foldl(a+b)
