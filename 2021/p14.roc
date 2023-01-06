app "day14"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Func, RichList, RichDict]
    provides [main] to pf

main =
    solve = \input ->

        lines = Str.trim input |> Str.split "\n"

        # Keep the polymer as Int list rather than strings
        initialPolymer = List.first lines |> Result.withDefault "" |> Str.toScalars
        ruleList =
            lines
            |> List.dropFirst
            |> List.dropFirst
            |> List.keepOks \line ->
                when Str.toScalars line is
                    [a1, a2, .., b] -> Ok (T (Pair a1 a2) b)
                    _ -> Err Malform
        rules = Dict.fromList ruleList

        # part 1
        # do it directly
        convert = \polymer ->
            List.map2 polymer (polymer |> List.dropFirst |> List.append 0) Pair
            |> List.joinMap \Pair x y ->
                when Dict.get rules (Pair x y) is
                    Ok z -> [x, z]
                    _ -> [x]

        polymer10 = Func.repeat convert 10 initialPolymer
        freq1 = RichList.frequency polymer10 Dict.empty |> Dict.values |> List.sortAsc
        ans1 =
            when freq1 is
                [a, .., z] -> Num.toStr (z - a)
                _ -> "Error!"

        # part 2
        # The polymer size is O(2**n), with n = 40 it's no longer feasible to produce the elements one by one.
        countDescendants = \lowerLevel ->
            List.map ruleList \T (Pair x y) m ->
                lh = Dict.get lowerLevel (Pair x m) |> Result.withDefault Dict.empty
                rh = Dict.get lowerLevel (Pair m y) |> Result.withDefault Dict.empty
                res = RichDict.merge lh rh Num.add |> RichDict.merge (Dict.single m 1) Num.add
                T (Pair x y) res
            |> Dict.fromList

        # level1 = RichDict.mapValues rules \m -> Dict.single m 1
        top = RichList.frequency initialPolymer Dict.empty

        finalDescendants = Func.repeat countDescendants 40 Dict.empty
        counter =
            List.map2 initialPolymer (initialPolymer |> List.dropFirst) Pair
            |> List.walk top \x, pair ->
                RichDict.merge x (Dict.get finalDescendants pair |> Result.withDefault Dict.empty) Num.add
        freq2 = counter |> Dict.values |> List.sortAsc
        ans2 =
            when freq2 is
                [a, .., z] -> Num.toStr (z - a)
                _ -> "Error!"

        { ans1, ans2 }

    Path.fromStr "data/14.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
