app "day15"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task]
    provides [main] to pf

main =
    solve = \input ->
        lines =
            Str.trim input
            |> Str.split "\n"

        initialCosts =
            lines
            |> List.mapWithIndex \row, r ->
                # keep the cell coordinates in 1-based indices to avoid overflow headaches
                Str.toScalars row |> List.map Num.toNat |> List.mapWithIndex \x, c -> T (Cell (r + 1) (c + 1)) (x - 48)
            |> List.join
            |> Dict.fromList

        initialH = List.len lines
        initialW = Dict.len initialCosts // initialH

        solveOnMap = \getCost, h, w ->

            neighbors = \Cell r c ->
                [
                    Cell (r - 1) c,
                    Cell r (c - 1),
                    Cell r (c + 1),
                    Cell (r + 1) c,
                ]
                |> List.keepIf \Cell nr nc -> nr > 0 && nc > 0 && nr <= h && nc <= w

            # Doing A*, with estimated remaining cost = manhattan distance from the current cell.
            # We don't have a min heap, so instead we maintain a cost dict and keep increasing by 1
            target = Cell h w
            z = h + w - 2 # max estimated remaining cost
            astar = \currentCost, fringes, visited ->
                currentFringe = Dict.get fringes currentCost |> Result.withDefault []
                when currentFringe is
                    [] ->
                        astar (currentCost + 1) fringes visited

                    [cell, ..] if cell == target ->
                        currentCost

                    [cell, ..] ->
                        withoutCurrent = Dict.insert fringes currentCost (List.dropFirst currentFringe)
                        if Set.contains visited cell then
                            astar currentCost withoutCurrent visited
                        else
                            (Cell x y) = cell
                            newFringes =
                                neighbors cell
                                |> List.dropIf \nb -> Set.contains visited nb
                                |> List.walk withoutCurrent \state, nb ->
                                    (Cell nx ny) = nb
                                    nbCost = getCost nb
                                    # estimated remaining cost = z - x - y + (true cost)
                                    newCost = currentCost + x + y + nbCost - nx - ny
                                    Dict.update state newCost \possibleValue ->
                                        when possibleValue is
                                            Missing -> Present [nb]
                                            Present xs -> Present (List.append xs nb)
                            astar currentCost newFringes (Set.insert visited cell)

            astar z (Dict.single z [Cell 1 1]) Set.empty

        ans1 = # 656
            getCost = \cell ->
                Dict.get initialCosts cell |> Result.withDefault 0
            solveOnMap getCost initialH initialW |> Num.toStr

        ans2 = # 2979
            # div/mod, but with range [1 to m]
            # cost for small grid x y within BIG GRID X Y is X + Y + cost(x, y)
            mod = \x, m -> (x - 1) % m + 1
            div = \x, m -> (x - 1) // m

            getCost = \Cell r c ->
                raw = Dict.get initialCosts (Cell (mod r initialH) (mod c initialW)) |> Result.withDefault 0
                mod (div r initialH + div c initialW + raw) 9
            solveOnMap getCost (initialH * 5) (initialW * 5) |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/15.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
