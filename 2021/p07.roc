app "day07"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task]
    provides [main] to pf

main =
    solve = \input ->
        nums = Str.trim input |> Str.split "," |> List.keepOks Str.toI32

        minPosition = List.min nums |> Result.withDefault 0
        maxPosition = List.max nums |> Result.withDefault 0

        # go through all choices of positions from min to max,
        # calculate the fuel according to the cost function,
        # pick the cheapest
        optimalFuel = \costFunc ->
            List.range { start: At minPosition, end: At maxPosition }
            |> List.map \x ->
                nums |> List.map \y -> costFunc x y 
                |> List.sum
            |> List.min |> Result.withDefault 0

        # part 1
        cost1 = \x, y -> Num.abs (x - y)
        ans1 = optimalFuel cost1 |> Num.toStr
        
        # part 2
        cost2 = \x, y ->
            d = cost1 x y
            (d * (d + 1)) // 2
        ans2 = optimalFuel cost2 |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/07.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
            Ok res -> 
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2
            Err _  -> Stderr.line "error!"
