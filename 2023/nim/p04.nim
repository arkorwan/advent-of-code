import strutils, sequtils, re, math

let input = readFile("../data/04.txt").strip.splitLines
var cards = repeat(1, input.len)
var score = 0

for i, line in input:
    let
        parts = line.split(re"[:\|]")
        a = parts[1].strip.splitWhitespace.mapIt(it.strip.parseInt)
        b = parts[2].strip.splitWhitespace.mapIt(it.strip.parseInt)
        c = b.countIt(a.contains(it))
    score += 2^c div 2
    for j in (i+1..i+c):
        cards[j] += cards[i]

# part 1
echo score

# part 2
echo cards.sum
