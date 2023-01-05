app "day11"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Func]
    provides [main] to pf

main =
    solve = \input ->
        initialCells =
            Str.trim input
            |> Str.split "\n"
            |> List.mapWithIndex \row, r ->
                # keep the cell coordinates in 1-based indices to avoid overflow headaches
                Str.toScalars row |> List.mapWithIndex \x, c -> T (Cell (r + 1) (c + 1)) (x - 48)
            |> List.join
            |> Dict.fromList

        neighbors = \Cell r c ->
            [
                Cell (r - 1) (c - 1),
                Cell (r - 1) c,
                Cell (r - 1) (c + 1),
                Cell r (c - 1),
                Cell r (c + 1),
                Cell (r + 1) (c - 1),
                Cell (r + 1) c,
                Cell (r + 1) (c + 1),
            ]
            |> List.keepIf \Cell nr nc -> nr > 0 && nc > 0 && nr <= 10 && nc <= 10

        # in each time step, put all the fish that need to have increased energy in a queue.
        # so initially all fish are put in queue.
        # as we process the queue, when we have 9 -> 10 increment then also put the neighboring fish in the queue.
        # after queue is cleared, reset the cells with energy > 9
        timeStep = \initialState ->
            cells = initialState.energy
            keys = Dict.keys cells
            processQueue = \cells1, q ->
                when q is
                    [h, ..] ->
                        tail = List.dropFirst q
                        when Dict.get cells1 h is
                            Ok 9 -> processQueue (Dict.insert cells1 h 10) (List.concat tail (neighbors h))
                            Ok x -> processQueue (Dict.insert cells1 h (x + 1)) tail
                            Err _ -> cells1

                    [] -> cells1

            increased = processQueue cells keys

            List.walk keys { initialState & currentFlashes: 0, energy: increased, step: initialState.step + 1 } \state, h ->
                when Dict.get state.energy h is
                    Ok x if x >= 10 ->
                        { state &
                            totalFlashes: state.totalFlashes + 1,
                            currentFlashes: state.currentFlashes + 1,
                            energy: Dict.insert state.energy h 0,
                        }

                    _ -> state

        # part 1
        finalState1 = Func.repeat timeStep 100 { totalFlashes: 0, currentFlashes: 0, energy: initialCells, step: 0 }
        ans1 = finalState1.totalFlashes |> Num.toStr

        # part 2
        allFlashes = \state ->
            state.currentFlashes == 100

        finalState2 = Func.repeatUntil timeStep allFlashes { totalFlashes: 0, currentFlashes: 0, energy: initialCells, step: 0 }
        ans2 = finalState2.step |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/11.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
