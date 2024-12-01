app "day03"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Binary, RichList]
    provides [main] to pf

main =
    solve = \input ->
        lines = Str.split input "\n"

        l =
            List.get lines 0
            |> Result.map Str.countGraphemes
            |> Result.withDefault 0

        # convert each binary string to List of 0/1 bits
        bits = List.map lines \str ->
            Str.toScalars str |> List.map \s -> Num.toNat (s - 48)

        # part 1
        ans1 =
            # calculate the sum (= count of 1) for each bit position
            counter = List.walk bits (List.repeat 0 l) \xs, ys ->
                List.map2 xs ys \x, y -> x + y 
            gamma =
                counter
                |> List.map \x ->
                    if x > List.len bits // 2 then 1 else 0
                |> Binary.listToNat
                |> Result.withDefault 0
            # epsilon is the bit inversion on gamma,
            # so we calculate the bitwise XOR of gamma and 2**l - 1
            epsilon = Num.bitwiseXor gamma ((1 |> Num.shiftLeftBy (Num.toU8 l)) - 1)    
            Num.toStr (gamma * epsilon)

        # part 2
        # recursively partition the list by the ith bits, and keep only one,
        # depending on the keepMostCommon flag.
        filter = \xs, keepMostCommon ->
            recur = \ys, i ->
                when ys is
                    [single] -> single
                    _ ->
                        partition = RichList.partition ys \y ->
                            when List.get y i is
                                Ok 1 -> Bool.true
                                _ -> Bool.false
                        more0 = List.len partition.whenFalse > List.len partition.whenTrue
                        # keep the false sublist if (1) b0 is larger and we want to keep the more common one,
                        # or (2) b1 is larger and we want to keep the less common one.
                        if more0 == keepMostCommon then
                            recur partition.whenFalse (i + 1)
                        else
                            recur partition.whenTrue (i + 1)
            recur xs 0

        ans2 =
            o2 = filter bits Bool.true |> Binary.listToNat |> Result.withDefault 0
            co2 = filter bits Bool.false |> Binary.listToNat |> Result.withDefault 0
            Num.toStr (o2 * co2)

        { ans1, ans2 }

    Path.fromStr "data/03.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
