app "day03"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Binary]
    provides [main] to pf

main =
    solve = \input ->
        lines = Str.split input "\n" |> List.map Str.trim
        l = List.get lines 0
            |> Result.map Str.countGraphemes
            |> Result.withDefault 0

        bits = List.map lines \str ->
            Str.toScalars str |> List.map \s -> Num.toNat (s - 48)

        # part 1

        counter = List.walk bits (List.repeat 0 l) \xs, ys ->
            List.map2 xs ys \x, y -> x + y

        gamma = counter
            |> List.map \x ->
                if x > (List.len bits) // 2 then 1 else 0
            |> Binary.listToNat
            |> Result.withDefault 0
        
        # bit inversion on gamma
        epsilon = Num.bitwiseXor gamma ((1 |> Num.shiftLeftBy (Num.toU8 l)) - 1)
        ans1 = Num.toStr (gamma * epsilon)

        # part 2

        filter = \xs, keepMostCommon ->
            recur = \ys, i ->
                when ys is
                [single] -> single
                _ ->
                    partition = List.walk ys {b0: [], b1: []} \state, y ->
                        when (List.get y i) is
                        Ok 0 -> {state & b0 : List.append state.b0 y}
                        Ok 1 -> {state & b1 : List.append state.b1 y}
                        _    -> state
                    more0 = (List.len partition.b0) > (List.len partition.b1)
                    if more0 == keepMostCommon then
                        recur partition.b0 (i + 1)
                    else
                        recur partition.b1 (i + 1)
            recur xs 0

        o2  = filter bits Bool.true  |> Binary.listToNat |> Result.withDefault 0
        co2 = filter bits Bool.false |> Binary.listToNat |> Result.withDefault 0
        ans2 = Num.toStr (o2 * co2)

        { ans1, ans2 }

    Path.fromStr "data/03.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
            Ok res -> 
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2
            Err _  -> Stderr.line "error!"
