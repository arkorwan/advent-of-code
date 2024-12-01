app "day21"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Func]
    provides [main] to pf

main =
    solve = \input ->

        lines = Str.split input "\n"
        extract = \line ->
            Str.split line " " |> List.last |> Result.try Str.toNat

        p1 = List.get lines 0 |> Result.try extract |> Result.withDefault 0
        p2 = List.get lines 1 |> Result.try extract |> Result.withDefault 0

        # modulo 10, but from 1 to 10
        mod10 = \x -> (x + 9) % 10 + 1

        # part 1
        #
        # Counting in (mod 10), the game state repeats after each player takes 10 turns.
        # (actually player 1 would repeat in just 5 turns).
        # So we can calculate up front for 10 turns, where would be the positions AWAY from the starting position.
        # Then calculate the points taken per full round, see how many full rounds the game would last,
        # and clean it up with the last (incomplete) round.
        ans1 =
            # positions at each step in the round
            a1 = [6, 0, 2, 2, 0, 6, 0, 2, 2, 0] # This is 1+2+3, 1+2+3 + 7+8+9, ...
            a2 = [5, 8, 9, 8, 5, 0, 3, 4, 3, 0] # This is 4+5+6, 4+5+6 + 10+1+2, ...
            # points from each step
            b1 = a1 |> List.map \a -> mod10 (a + p1)
            b2 = a2 |> List.map \a -> mod10 (a + p2)

            # total points per a full round
            s1 = List.sum b1
            s2 = List.sum b2
            sm = if s1 > s2 then s1 else s2

            # how many full rounds it would last
            rounds = 1000 // sm

            moveLastRound = \player, index, rolls, thisScore, otherScore ->
                if otherScore >= 1000 then
                    { rolls, losingScore: thisScore }
                else if player == PlayerOne then
                    score = List.get b1 index |> Result.withDefault 0
                    moveLastRound PlayerTwo index (rolls + 3) otherScore (thisScore + score)
                else
                    score = List.get b2 index |> Result.withDefault 0
                    moveLastRound PlayerOne (index + 1) (rolls + 3) otherScore (thisScore + score)
            finalState = moveLastRound PlayerOne 0 (rounds * 60) (rounds * s1) (rounds * s2)
            finalState.rolls * finalState.losingScore |> Num.toStr

        # part 2
        #
        # We can count the number of worlds for each player separately. The worlds can be grouped into states with 3 parameters:
        # (turns taken, score, board position). Without the "time dimention" we have states (score, position),
        # and we can derive the number of worlds in each state from the number of worlds in the previous time step.
        # At each step we also count how many worlds have reached the winning score, and also how many are still active.
        # Once we have these numbers for both players, we can caculate the winning worlds for player 1,
        # as the sum of (P1's winning worlds in turn x * P2's active worlds in turn (x-1)).
        # Similarly the winning for player 2 is: the sum of (P2's winning worlds in turn x * P1's active worlds in turn x).
        #
        # Note: lots of problems with the compiler... without using "Func.takeUntil" we could not find a way
        # to write a working recursive counting function.
        ans2 =

            updateWorlds = \dict, state, worlds ->
                Dict.update dict state \current ->
                    when current is
                        Missing -> Present worlds
                        Present w -> Present (w + worlds)

            branches = [
                { steps: 3, worlds: 1 }, # 1+1+1 (1)
                { steps: 4, worlds: 3 }, # 2+1+1 (3)
                { steps: 5, worlds: 6 }, # 3+1+1 (3), 2+2+1 (3)
                { steps: 6, worlds: 7 }, # 3+2+1 (6), 2+2+2 (1)
                { steps: 7, worlds: 6 }, # 3+3+1 (3), 3+2+2 (3)
                { steps: 8, worlds: 3 }, # 3+3+2 (3)
                { steps: 9, worlds: 1 }, # 3+3+3 (1)
            ]

            roll123 = \states ->
                Dict.walk states Dict.empty \nextStates, S score index, worlds ->
                    if score == 21 then
                        nextStates
                    else
                        List.walk branches nextStates \nextStates2, update ->
                            newIndex = mod10 (update.steps + index)
                            newScore = newIndex + score
                            if newScore >= 21 then
                                updateWorlds nextStates2 (S 21 0) (worlds * update.worlds)
                            else
                                updateWorlds nextStates2 (S newScore newIndex) (worlds * update.worlds)

            initialP1 = Dict.empty |> Dict.insert (S 0 p1) 1
            initialP2 = Dict.empty |> Dict.insert (S 0 p2) 1

            countWorlds = \dict ->
                allWorlds = Dict.walk dict 0 \s, _, w -> s + w
                winningWorlds = Dict.get dict (S 21 0) |> Result.withDefault 0
                { winningWorlds, activeWorlds: allWorlds - winningWorlds }

            w1 = Func.takeUntil roll123 (\states -> Dict.len states == 0) initialP1 |> List.map countWorlds
            w2 = Func.takeUntil roll123 (\states -> Dict.len states == 0) initialP2 |> List.map countWorlds

            p1Winning =
                List.map2 (List.dropFirst w1) w2 \x, y -> x.winningWorlds * y.activeWorlds
                |> List.sum
            p2Winning =
                List.map2 w2 w1 \x, y -> x.winningWorlds * y.activeWorlds
                |> List.sum

            (if p1Winning > p2Winning then p1Winning else p2Winning) |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/21.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
