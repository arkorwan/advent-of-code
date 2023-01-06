app "day13"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, RichList]
    provides [main] to pf

main =
    solve = \input ->

        inputParts = Str.trim input |> Str.split "\n\n"

        initialPts =
            List.first inputParts
            |> Result.withDefault ""
            |> Str.split "\n"
            |> List.keepOks \l ->
                when Str.split l "," |> List.map Str.toI32 is
                    [Ok x, Ok y] -> Ok (Cell x y)
                    _ -> Err Malform

        foldCommands =
            List.last inputParts
            |> Result.withDefault ""
            |> Str.split "\n"
            |> List.keepOks \l ->
                when Str.split l "=" is
                    [a, b] if Str.endsWith a "x" -> Ok (X (Result.withDefault (Str.toI32 b) 0))
                    [a, b] if Str.endsWith a "y" -> Ok (Y (Result.withDefault (Str.toI32 b) 0))
                    _ -> Err Malform

        fold = \pts, cmd ->
            ls =
                when cmd is
                    X d -> List.map pts \Cell x y -> Cell (d - Num.abs (x - d)) y
                    Y d -> List.map pts \Cell x y -> Cell x (d - Num.abs (y - d))
            ls |> Set.fromList |> Set.toList

        # part 1
        ans1 = foldCommands |> List.takeFirst 1 |> List.walk initialPts fold |> List.len |> Num.toStr

        # part 2
        folded = foldCommands |> List.walk initialPts fold
        xMax = folded |> List.map (\Cell x _ -> x) |> List.max |> Result.withDefault 0
        yMax = folded |> List.map (\Cell _ y -> y) |> List.max |> Result.withDefault 0
        lookup = Set.fromList folded

        ans2 =
            List.range { start: At 0, end: At yMax }
            |> List.walk "" \s1, r ->
                row =
                    List.range { start: At 0, end: At xMax }
                    |> List.walk "" \s2, c ->
                        if Set.contains lookup (Cell c r) then
                            "\(s2)█"
                        else
                            "\(s2) "
                "\(s1)\n\(row)"

        { ans1, ans2 }

    Path.fromStr "data/13.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
