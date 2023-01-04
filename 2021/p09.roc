app "day09"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Func]
    provides [main] to pf

main =
    solve = \input ->
        m =
            Str.trim input
            |> Str.split "\n"
            |> List.map \row ->
                Str.toScalars row |> List.map \x -> x - 48
        h = List.len m |> Num.toI16
        w = List.first m |> Result.map List.len |> Result.withDefault 0 |> Num.toI16

        # Bug? this function breaks if we refer directly to the m 'array' instead of passing it in
        atCoord = \a, r, c ->
            if r < 0 || c < 0 then
                Err OutOfBounds
            else
                a |> List.get (Num.toNat r) |> Result.try \row -> List.get row (Num.toNat c)

        cells =
            List.range { start: At 0, end: Before h }
            |> List.joinMap \r ->
                List.range { start: At 0, end: Before w }
                |> List.map \c -> Cell r c

        # part 1
        ans1 =
            List.walk cells 0 \s, Cell r c ->
                current = atCoord m r c |> Result.withDefault 0
                neighbors = [
                    atCoord m (r - 1) c,
                    atCoord m (r + 1) c,
                    atCoord m r (c - 1),
                    atCoord m r (c + 1),
                ]
                isLowPoint = List.keepOks neighbors Func.identity |> List.all \x -> x > current
                if isLowPoint then s + current + 1 else s
            |> Num.toStr

        # part 2
        # A cell can be expanded iff it's in bounds, ts height is not 9, and it hasn't been visited before
        # Same problem/bug with `atCoord` -- we cannot refer to m directly.
        isExpandable = \a, Cell r c, doneSet ->
            when atCoord a r c is
                Err _ -> Bool.false
                Ok 9 -> Bool.false
                Ok _ -> !(Set.contains doneSet (Cell r c))

        # Workhorse of the BFS
        expand = \state ->
            when state.fringe is
                [cell, ..] if Set.contains state.done cell -> expand { state & fringe: List.dropFirst state.fringe }
                [Cell r c, ..] ->
                    neighbors = [
                        Cell (r - 1) c,
                        Cell (r + 1) c,
                        Cell r (c - 1),
                        Cell r (c + 1),
                    ]
                    newFringe = List.dropFirst state.fringe |> List.concat (List.keepIf neighbors \nb -> isExpandable m nb state.done)
                    expand { state & fringe: newFringe, done: Set.insert state.done (Cell r c), size: state.size + 1 }

                _ -> state

        # BFS, trying to start a new basin from every node.
        finalState =
            List.walk cells { done: Set.empty, basins: [] } \state, cell ->
                if isExpandable m cell state.done then
                    basin = expand { fringe: [cell], done: state.done, size: 0 }
                    { state & done: basin.done, basins: List.append state.basins basin.size }
                else
                    state

        ans2 = List.sortDesc finalState.basins |> List.takeFirst 3 |> List.product |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/09.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
