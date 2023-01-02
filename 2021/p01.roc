app "day01"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task]
    provides [main] to pf

main =
    solve = \input ->
        lines = Str.split input "\n"
        nums = lines |> List.keepOks Str.toU16
        
        # part 1
        ans1 = List.map2 nums (List.dropFirst nums) Pair
            |> List.countIf \Pair x y -> x < y
            |> Num.toStr
        
        # part 2
        triples = List.map3 nums (List.dropFirst nums) (List.drop nums 2) \x, y, z -> x + y + z
        ans2 = List.map2 triples (List.dropFirst triples) Pair
            |> List.countIf \Pair x y -> x < y
            |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/01.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
            Ok res -> 
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2
            Err _  -> Stderr.line "error!"
