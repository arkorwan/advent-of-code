app "day06"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, RichList, Func]
    provides [main] to pf

main =
    solve = \input ->
        ages = Str.trim input |> Str.split "," |> List.keepOks Str.toNat
        day0 = RichList.frequency ages Dict.empty
        getOr0 = \dict, i -> Dict.get dict i |> Result.withDefault 0

        # part 1
        # state transition
        transition = \prev ->
            Dict.empty
            |> Dict.insert 0 (getOr0 prev 1)
            |> Dict.insert 1 (getOr0 prev 2)
            |> Dict.insert 2 (getOr0 prev 3)
            |> Dict.insert 3 (getOr0 prev 4)
            |> Dict.insert 4 (getOr0 prev 5)
            |> Dict.insert 5 (getOr0 prev 6)
            |> Dict.insert 6 (getOr0 prev 7 + getOr0 prev 0)
            |> Dict.insert 7 (getOr0 prev 8)
            |> Dict.insert 8 (getOr0 prev 0)

        day80 = Func.repeat transition 80 day0
        ans1 =
            Dict.walk day80 0 \state, _, v ->
                state + v
            |> Num.toStr

        # part 2
        day256 = Func.repeat transition (256 - 80) day80
        ans2 =
            Dict.walk day256 0 \state, _, v ->
                state + v
            |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/06.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
