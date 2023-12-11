import strutils, sequtils

let
    input = readFile("../data/11.txt").strip.splitLines
    h1 = input.len
    w1 = input[0].len
var emptyRows: set[int16] = {}
var emptyCols: set[int16] = {}

for i, line in input:
    if not line.contains('#'):
        emptyRows.incl(i.int16)
for j in (0..w1-1):
    if not input.mapIt(it[j]).contains('#'):
        emptyCols.incl(j.int16)

type Galaxy = tuple[x: int16, xOffset: int16, y: int16, yOffset: int16]
var galaxies: seq[Galaxy] = @[]

var iOffset = 0.int16
for i in (0..h1-1):
    if emptyRows.contains(i.int16): iOffset += 1
    var jOffset = 0.int16
    for j in (0..w1-1):
        if emptyCols.contains(j.int16): jOffset += 1
        if input[i][j] == '#':
            galaxies.add((i.int16, iOffset, j.int16, jOffset))

func allPairsDistance(galaxies: seq[Galaxy], expansion: int): int64 =
    let m = (expansion - 1).int64
    var s = 0.int64
    for i, g1 in galaxies:
        for j in (i+1..galaxies.len-1):
            let
                g2 = galaxies[j]
                dx = ((g1.x - g2.x).int64 + (g1.xOffset - g2.xOffset).int64 * m).abs
                dy = ((g1.y - g2.y).int64 + (g1.yOffset - g2.yOffset).int64 * m).abs
            s += dx+dy
    s

# part 1
echo allPairsDistance(galaxies, 2)

# part 2
echo allPairsDistance(galaxies, 1000000)
