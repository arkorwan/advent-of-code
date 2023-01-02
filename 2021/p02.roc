app "day02"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task]
    provides [main] to pf

main =
    solve = \input ->
        commands = Str.split input "\n"
            |> List.keepOks \line ->
                args = Str.split line " " |> List.map Str.trim
                when args is
                    [x1, x2] -> when Str.toI32 x2 is
                        Ok steps -> Ok (Command x1 steps)
                        _ -> Err "integer conversion failed" 
                    _ -> Err "need list of size 2"
        ans1 = 
            fold = List.walk commands { x: 0, y: 0} \state, Command direction steps ->
                when direction is
                    "forward" -> { state & x: state.x + steps }
                    "up"      -> { state & y: state.y - steps }
                    "down"    -> { state & y: state.y + steps }
                    _         -> state
            Num.toStr (fold.x * fold.y)

        ans2 = 
            fold = List.walk commands { x: 0, y: 0, aim: 0} \state, Command direction steps ->
                when direction is
                    "forward" -> { state & x: state.x + steps, y: state.y + state.aim * steps }
                    "up"      -> { state & aim: state.aim - steps }
                    "down"    -> { state & aim: state.aim + steps }
                    _         -> state
            Num.toStr (fold.x * fold.y)
            
        { ans1, ans2 }

    Path.fromStr "data/02.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
                Ok res -> 
                    _ <- Task.await (Stdout.line res.ans1)
                    Stdout.line res.ans2
                Err _  -> Stderr.line "error!"
