app "day10"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task]
    provides [main] to pf

main =
    solve = \input ->
        lines = Str.trim input |> Str.split "\n"

        pairs =
            Dict.empty
            |> Dict.insert ")" "("
            |> Dict.insert "]" "["
            |> Dict.insert "}" "{"
            |> Dict.insert ">" "<"

        checkBalance = \str ->
            List.walkUntil (Str.graphemes str) { stack: [], status: Good } \state, c ->
                when { lookup: Dict.get pairs c, stack: state.stack } is
                    { lookup: Ok x, stack: [.., y] } if x == y -> # Close & match
                        Continue { state & stack: List.dropLast state.stack }

                    { lookup: Ok _, stack: _ } -> # Close but not match / empty
                        Break { state & status: Corrupted c }

                    _ -> # Open
                        Continue { state & stack: List.append state.stack c }

        balanceStatus = lines |> List.map checkBalance
        # part 1
        ans1 =
            balanceStatus
            |> List.walk 0 \s, res ->
                when res.status is
                    Corrupted ")" -> s + 3
                    Corrupted "]" -> s + 57
                    Corrupted "}" -> s + 1197
                    Corrupted ">" -> s + 25137
                    _ -> s
            |> Num.toStr

        # part 2
        # completion string is just the stack in reverse,
        # so we can just walk backwards on the stack.
        scoreFromStack = \stack ->
            List.walkBackwards stack 0 \score, c ->
                when c is
                    "(" -> score * 5 + 1
                    "[" -> score * 5 + 2
                    "{" -> score * 5 + 3
                    "<" -> score * 5 + 4
                    _ -> score

        scores =
            List.keepOks balanceStatus \res ->
                when res.status is
                    Corrupted _ -> Err Corrupted
                    Good -> Ok (scoreFromStack res.stack)
            |> List.sortAsc

        ans2 = List.get scores (List.len scores // 2) |> Result.withDefault 0 |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/10.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
