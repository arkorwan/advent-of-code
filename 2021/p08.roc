app "day08"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task]
    provides [main] to pf

main =
    solve = \input ->
        wirings = Str.trim input |> Str.split "\n" 
            |> List.map Str.trim 
            |> List.map (\line -> Str.split line " ")

        # part 1
        displays = List.joinMap wirings \xs -> List.takeLast xs 4
        uniqs = displays |> List.countIf \s ->
            l = Str.countGraphemes s
            l <= 4 || l == 7
        ans1 = Num.toStr uniqs
        
        # part 2

        # 'canonize' the given pattern string into a sorted list of Num 
        canonize = \pattern -> Str.toScalars pattern |> List.sortAsc
        intersect = \xs1, xs2 -> List.keepIf xs1 \i -> List.contains xs2 i
        defaultList = \xs -> Result.withDefault xs []

        inferPattern = \patterns ->
            canons = List.map patterns canonize
            c5 = List.keepIf canons \p -> List.len p == 5
            c6 = List.keepIf canons \p -> List.len p == 6
            
            p1 = List.findFirst canons (\p -> List.len p == 2) |> defaultList
            p4 = List.findFirst canons (\p -> List.len p == 4) |> defaultList
            p7 = List.findFirst canons (\p -> List.len p == 3) |> defaultList
            p8 = List.findFirst canons (\p -> List.len p == 7) |> defaultList

            # among 0, 6, 9: 6 is the only one that have 1 common segment with 1
            p6 = List.findFirst c6 (\p -> List.len (intersect p p1) == 1) |> defaultList
            # 0 has 3 common segment with 4, while 9 has 4
            p0 =
                List.findFirst c6 \p ->
                    (p != p6) && (List.len (intersect p p4) == 3)
                |> Result.withDefault []
            p9 = List.findFirst c6 (\p -> p != p6 && p != p0) |> defaultList

            # among 2, 3, 5: 3 is the only one that have 2 common segments with 1
            p3 = List.findFirst c5 (\p -> List.len (intersect p p1) == 2) |> defaultList
            # and 2 is the only one that have 2 common segments with 4
            p2 = List.findFirst c5 (\p -> List.len (intersect p p4) == 2) |> defaultList
            p5 = List.findFirst c5 (\p -> p != p2 && p != p3) |> defaultList
            
            Dict.empty
                |> Dict.insert p0 0
                |> Dict.insert p1 1
                |> Dict.insert p2 2
                |> Dict.insert p3 3
                |> Dict.insert p4 4
                |> Dict.insert p5 5
                |> Dict.insert p6 6
                |> Dict.insert p7 7
                |> Dict.insert p8 8
                |> Dict.insert p9 9
        
        constructDisplay = \patterns, inference ->
            patterns 
                |> List.map canonize
                |> List.keepOks \p -> Dict.get inference p
                |> List.walk 0 \n, i -> 10*n + i

        ans2 = wirings 
            |> List.map \ws ->
                inference = inferPattern (List.takeFirst ws 10)
                displayPatterns = List.takeLast ws 4
                constructDisplay displayPatterns inference
            |> List.sum
            |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/08.txt"
        |> File.readUtf8
        |> Task.map solve
        |> Task.attempt \result ->
            when result is
            Ok res -> 
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2
            Err _  -> Stderr.line "error!"
