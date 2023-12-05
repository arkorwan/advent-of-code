import strutils, strformat, sequtils, tables, math

let
    input = readFile("../data/03.txt").strip.splitLines
    h = input.len
    w = input[0].len
    cleanInput = ".".repeat(h+2) & input.mapIt(fmt".{it}.") & ".".repeat(h+2)

func isDigit(c: char): bool =
    c >= '0' and c <= '9'

# state variables
var
    partsSum = 0
    allGears = initTable[(int, int), seq[int]]()
    currentNum = 0
    isValidPart = false
    currentGears: seq[(int, int)] = @[]

proc checkAdjacent(adj: seq[(int, int)]) =
    for elem in adj:
        let c = cleanInput[elem[0]][elem[1]]
        if c != '.' and not isDigit(c):
            isValidPart = true
            currentGears.add(elem)

proc reset() =
    if currentNum > 0 and isValidPart:
        partsSum += currentNum
        for elem in currentGears:
            if not allGears.contains(elem):
                allGears[elem] = @[currentNum]
            else:
                allGears[elem].add(currentNum)
    currentNum = 0
    isValidPart = false
    currentGears = @[]

for j in 1..h:
    for i in 1..w:
        let c = cleanInput[j][i]
        if currentNum > 0:
            if isDigit(c):
                currentNum = currentNum*10 + int(c) - int('0')
                checkAdjacent(@[(j-1, i+1), (j+1, i+1)])
            else:
                checkAdjacent(@[(j, i)])
                reset()
        elif isDigit(c):
            currentNum = int(c) - int('0')
            checkAdjacent(@[(j-1, i-1), (j-1, i), (j-1, i+1), (j, i-1), (j+1,
                    i-1), (j+1, i), (j+1, i+1)])
    reset()

# part 1
echo partsSum

# part 2
echo allGears.values.toSeq.filterIt(it.len == 2).mapIt(it[0]*it[1]).sum
