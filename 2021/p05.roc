app "day05"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, RichList]
    provides [main] to pf

main =
    solve = \input ->
        segments = Str.split input "\n" |> List.keepOks \l -> 
            line = Str.split l " -> " |> List.joinMap \coord ->
                Str.split coord "," |> List.keepOks Str.toI32
            when line is
            [x1, y1, x2, y2] -> Ok { x1, y1, x2, y2 }
            _ -> Err InvalidSegment

        { whenTrue: perpendiculars, whenFalse: diagonals } = RichList.partition segments \s -> (s.x1 == s.x2) || (s.y1 == s.y2)

        increment = \dict, key -> 
            Dict.update dict key \current ->
                when current is
                Missing -> Present 1
                Present x -> Present (x + 1)
        
        sort2 = \n1, n2 -> if n1 <= n2 then {min: n1, max: n2} else {min: n2, max: n1}

        # part 1

        # track all the coordinates in a Dict
        counter1 = List.walk perpendiculars Dict.empty \ct1, segment ->
            if segment.x1 == segment.x2 then
                ordered = sort2 segment.y1 segment.y2
                List.range { start: At ordered.min, end: At ordered.max }
                    |> List.walk ct1 \ct2, i ->
                        increment ct2 {x: segment.x1, y: i}
            else
                ordered = sort2 segment.x1 segment.x2
                List.range { start: At ordered.min, end: At ordered.max }
                    |> List.walk ct1 \ct2, i ->
                        increment ct2 {x: i, y: segment.y1}
        
        ans1 = Dict.walk counter1 0 ( \n, _, v -> if v == 1 then n else n + 1 )
            |> Num.toStr
        
        # part 2

        # start with the Dict from part 1, add the diagonals
        counter2 = List.walk diagonals counter1 \ct1, segment ->
            ordered = sort2 segment.x1 segment.x2
            if segment.x1 - segment.y1 == segment.x2 - segment.y2 then
                List.range { start: At ordered.min, end: At ordered.max }
                    |> List.walk ct1 \ct2, i ->
                        increment ct2 {x: i, y: i - segment.x1 + segment.y1 }
            else
                List.range { start: At ordered.min, end: At ordered.max }
                    |> List.walk ct1 \ct2, i ->
                        increment ct2 {x: i, y: segment.x1 + segment.y1 - i }

        ans2 = Dict.walk counter2 0 ( \n, _, v -> if v == 1 then n else n + 1 )
            |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/05.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
            Ok res -> 
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2
            Err _  -> Stderr.line "error!"
