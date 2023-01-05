app "day12"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, RichList]
    provides [main] to pf

main =
    solve = \input ->

        tunnels = Str.trim input |> Str.split "\n"

        # Connections: Map from a cave to everywhere it can go
        # This is two-way, so an x-y connection creates 2 entries.
        # Except 'start' can only be a source and 'end' can only be the destination.
        addConnection = \dict, x, y ->
            if x == "end" || y == "start" then
                dict
            else
                Dict.update dict x \current ->
                    when current is
                        Missing -> Present [y]
                        Present ls -> Present (List.append ls y)

        rawConnections =
            tunnels
            |> List.walk Dict.empty \state, tunnel ->
                when Str.split tunnel "-" is
                    [x, y] -> state |> addConnection x y |> addConnection y x
                    _ -> state

        isUpper = \s -> Str.toScalars s |> List.takeFirst 1 |> List.any \c -> c < 95

        # The BIG CAVES can be removed, and replaced by connecting all its destinations together.
        # This means there can be more than one way to connects two caves, so we count them.
        multiConnections = Dict.walk rawConnections Dict.empty \state, cave, dests ->
            if isUpper cave then
                state
            else
                multiDests = List.joinMap dests \d ->
                    if isUpper d then
                        Dict.get rawConnections d |> Result.withDefault []
                    else
                        [d]
                freq = RichList.frequency multiDests Dict.empty |> Dict.toList
                Dict.insert state cave freq

        # Count the path in a bottom-up manner.
        # repeatQuota is the number of times we are allowed to revisit the same cave.
        pathCount = \from, visited, repeatQuota, conns ->
            repeating = Set.contains visited from
            if from == "end" then
                1
            else if repeating && repeatQuota == 0 then
                0
            else
                newVisited = Set.insert visited from
                newQuota = if repeating then repeatQuota - 1 else repeatQuota
                dests = Dict.get conns from |> Result.withDefault []
                List.map dests \T d c -> pathCount d newVisited newQuota conns * c
                |> List.sum

        # part 1
        ans1 = pathCount "start" Set.empty 0 multiConnections |> Num.toStr

        # part 2
        ans2 = pathCount "start" Set.empty 1 multiConnections |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/12.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
