import strutils, sets

var input = readFile("../data/10.txt").strip.splitLines

func findS(input: seq[string]): (int, int) =
    for i, line in input:
        let j = line.find('S')
        if j >= 0: return (i, j)
    (-1, -1)

proc replaceS(input: var seq[string], c: (int, int)): void =
    let (x0, y0) = c
    var mask = 0
    if "-FL".contains(input[x0-1][y0]): mask += 1
    if "-7J".contains(input[x0+1][y0]): mask += 2
    if "|F7".contains(input[x0][y0-1]): mask += 4
    if "|LJ".contains(input[x0][y0+1]): mask += 8
    let k = case mask:
        of 3: '-'
        of 5: 'J'
        of 9: '7'
        of 6: 'L'
        of 10: 'F'
        else: '|'
    input[x0][y0] = k

func buildCycle(input: seq[string], start: (int, int)): HashSet[(int, int)] =
    var
        cycle = initHashSet[(int, int)]()
        c = start
        prevC = (-1, -1)
    while not cycle.contains(c):
        cycle.incl(c)
        let (x, y) = c
        let cands = case input[x][y]:
            of '-': ((x, y-1), (x, y+1))
            of '|': ((x-1, y), (x+1, y))
            of 'L': ((x-1, y), (x, y+1))
            of 'J': ((x-1, y), (x, y-1))
            of 'F': ((x+1, y), (x, y+1))
            else: ((x+1, y), (x, y-1))
        let nextC = if cands[0] == prevC: cands[1] else: cands[0]
        prevC = c
        c = nextC
    cycle

func countArea(input: seq[string], cycle: HashSet[(int, int)]): int =
    var area = 0
    for x, line in input:
        var inside = false
        var sectionStart = 0.char
        for y, q in line:
            if cycle.contains((x, y)):
                case q:
                of '-':
                    discard
                of '|':
                    inside = not inside
                of '7':
                    if sectionStart == 'L': inside = not inside
                    sectionStart = 0.char
                of 'J':
                    if sectionStart == 'F': inside = not inside
                    sectionStart = 0.char
                else:
                    sectionStart = q
            elif inside:
                area += 1
    area

let startingS = findS(input)
replaceS(input, startingS)
let cycle = buildCycle(input, startingS)

# part 1
echo cycle.len div 2

# part 2
echo countArea(input, cycle)
