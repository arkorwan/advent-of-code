import strutils, sequtils, options, tables, sugar, algorithm, math

const
    partitions = @[@[5], @[1, 4], @[2, 3], @[1, 1, 3], @[1, 2, 2], @[1, 1, 1,
            2], @[1, 1, 1, 1, 1]]
    cardValues1 = "AKQJT98765432".pairs.toSeq.mapIt((it[1], it[0])).toTable
    cardValues2 = "AKQT98765432J".pairs.toSeq.mapIt((it[1], it[0])).toTable

let
    input = readFile("../data/07.txt").strip.splitLines.mapIt(
            it.splitWhitespace)

proc lexicographic(x, y: seq[int]): int =
    if x.len == 0 or y.len == 0:
        x.len - y.len
    elif x[0] == y[0]:
        lexicographic(x[1..^1], y[1..^1])
    else:
        x[0] - y[0]

func getType(hands: seq[int], joker: Option[int]): int =
    let handsWithoutJoker = joker.map(j => hands.filterIt(it != j)).get(hands)
    if(handsWithoutJoker.len == 0):
        0
    else:
        var sortedCounter = handsWithoutJoker.toCountTable().values.toSeq.sorted
        sortedCounter[sortedCounter.len - 1] += 5 - handsWithoutJoker.len
        partitions.find(sortedCounter)

proc calc(input: seq[seq[string]], cardValues: Table[char, int], joker: Option[int]): int =
    input.map(proc(parts: auto): auto =
        let
            hands = parts[0].mapIt(cardValues[it])
            t = getType(hands, joker)
        (@[t] & hands, parts[1].parseInt)
    )
    .sorted((x, y: auto) => lexicographic(x[0], y[0]))
    .reversed.pairs.toSeq
    .mapIt((it[0]+1) * it[1][1])
    .sum

# part 1
echo calc(input, cardValues1, none(int))

# part 2
echo calc(input, cardValues2, some(12))
