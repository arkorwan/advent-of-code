app "day04"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, RichList]
    provides [main] to pf

main =
    solve = \input ->
        parts = Str.split input "\n\n" |> List.map Str.trim

        # take the first line, parse it as a List of number. This can be used to look up the called number by order.
        [calls] = List.takeFirst parts 1
        parsedCalls = calls
            |> Str.split "," 
            |> List.keepOks Str.toNat
        
        # also make a reverse lookup to get the order by number
        callOrder = parsedCalls
            |> List.mapWithIndex T 
            |> Dict.fromList

        # parse the boards, attaching the call order to every number
        boards = List.dropFirst parts |> List.map \boardStr ->
            Str.split boardStr "\n" |> List.map \row ->
                natRow = Str.split row " " |> List.map Str.trim |> List.keepOks Str.toNat
                List.keepOks natRow \e ->
                    Dict.get callOrder e |> Result.map \i -> { item: e, order: i }

        # determine which turn each board would be complete
        # Take the max call order on each row, and the max call order on each column
        # The minimum of these 10 numbers is the turn it would be complete
        completionOrder = List.map boards \rows ->
            maxByRow = rows |> List.keepOks (\row -> List.map row .order |> List.max)
            maxByCol = List.walk rows (List.repeat 0 5) \state, row ->
                List.map2 state row \x, y -> if x > y.order then x else y.order
            order = List.concat maxByRow maxByCol |> List.min |> Result.withDefault 0
            {board: rows, order}
        
        # score calculation
        boardScore = \board, endAt ->
            remain = board 
                |> List.map \row -> 
                    row
                        |> List.map (\x -> if x.order > endAt then x.item else 0) 
                        |> List.sum
                |> List.sum
            winningNumber = List.get parsedCalls endAt |> Result.withDefault 0
            remain * winningNumber

        # part 1
        firstWin = completionOrder |> RichList.minBy .order
        ans1 = when firstWin is
            Ok b -> Num.toStr (boardScore b.board b.order)
            _ -> "Error"

        # part 2
        lastWin = completionOrder |> RichList.maxBy .order
        ans2 = when lastWin is
            Ok b -> Num.toStr (boardScore b.board b.order)
            _ -> "Error"

        { ans1, ans2 }

    Path.fromStr "data/04.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
            Ok res -> 
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2
            Err _  -> Stderr.line "error!"
