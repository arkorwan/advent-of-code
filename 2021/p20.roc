app "day20"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Func, Binary]
    provides [main] to pf

main =
    solve = \input ->

        lines = Str.trim input |> Str.split "\n"

        parse = \c -> if c == "#" then Light else Dark

        # Notice the lookup value for 0 (all Dark) is Light, while lookup for 511 (all Light) is Dark.
        # This means most of this infinite space will flip back and forth between Light and Dark
        # in each step, except for our little patch. So we keep track of the default value
        # (whether we have infinite Dark or infinite Light), and record only cells that differ from
        # default.
        lookup = List.first lines |> Result.withDefault "" |> Str.graphemes |> List.map parse

        initialLightCells =
            lines
            |> List.dropFirst
            |> List.dropFirst
            |> List.map Str.trim
            |> List.mapWithIndex \row, r ->
                Str.graphemes row
                |> List.mapWithIndex \x, c ->
                    if x == "#" then Ok { r: r + 100, c: c + 100 } else Err Dark
            |> List.join
            |> List.keepOks Func.identity
            |> Set.fromList

        doLookup = \default, cells, cell, h ->
            pos =
                [
                    Set.contains cells { r: cell.r - 1, c: cell.c - 1 },
                    Set.contains cells { r: cell.r - 1, c: cell.c },
                    Set.contains cells { r: cell.r - 1, c: cell.c + 1 },
                    Set.contains cells { r: cell.r, c: cell.c - 1 },
                    Set.contains cells { r: cell.r, c: cell.c },
                    Set.contains cells { r: cell.r, c: cell.c + 1 },
                    Set.contains cells { r: cell.r + 1, c: cell.c - 1 },
                    Set.contains cells { r: cell.r + 1, c: cell.c },
                    Set.contains cells { r: cell.r + 1, c: cell.c + 1 },
                ]
                |> List.map \b -> if b != (default == Light) then 1 else 0
                |> Binary.listToNat
                |> Result.withDefault 0
            List.get h pos |> Result.withDefault default

        flip = \{ default, cells } ->
            cellList = Set.toList cells
            rs = cellList |> List.map .r
            cs = cellList |> List.map .c
            minR = (List.min rs |> Result.withDefault 0) - 1
            maxR = (List.max rs |> Result.withDefault 0) + 1
            minC = (List.min cs |> Result.withDefault 0) - 1
            maxC = (List.max cs |> Result.withDefault 0) + 1

            nextDefault = if default == Light then Dark else Light
            candidates =
                List.range { start: At minR, end: At maxR }
                |> List.joinMap \r ->
                    List.range { start: At minC, end: At maxC }
                    |> List.map \c -> { r, c }

            nextCells =
                candidates
                |> List.walk Set.empty \state, cell ->
                    res = doLookup default cells cell lookup
                    if res == nextDefault then
                        state
                    else
                        state |> Set.insert cell

            { default: nextDefault, cells: nextCells }

        # part 1
        ans1 =
            Func.repeat flip 2 { default: Dark, cells: initialLightCells }
            |> .cells
            |> Set.len
            |> Num.toStr

        # part 2
        ans2 =
            Func.repeat flip 50 { default: Dark, cells: initialLightCells }
            |> .cells
            |> Set.len
            |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/20.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
