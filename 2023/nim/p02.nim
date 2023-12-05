import strutils, sequtils, re, tables, math

const colors = {"red": 0, "green": 1, "blue": 2}.toTable
let
    input = readFile("../data/02.txt").splitLines
    games = input.map(proc(line: auto): auto =
        let
            parts = line.split(re"[:;]")
            id = parts[0].split(' ')[1].parseInt
            res = parts[1..^1].map(proc(it: auto): auto =
                var rgb = @[0, 0, 0]
                for desc in it.strip.split(','):
                    let x = desc.strip.split(' ', 2)
                    rgb[colors[x[1]]] = x[0].parseInt
                rgb
            )
        (id, res)
    )

# part 1
echo games.map(proc(game: auto): auto =
    let valid = game[1].allIt(it[0] <= 12 and it[1] <= 13 and it[2] <= 14)
    if valid: game[0] else: 0
    )
    .sum

# part 2
echo games.map(proc(game: auto): auto =
    let
        r = game[1].mapIt(it[0]).max
        g = game[1].mapIt(it[1]).max
        b = game[1].mapIt(it[2]).max
    r*g*b
    )
    .sum
