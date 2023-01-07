app "day16"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Binary, Func, RichList]
    provides [main] to pf

main =
    solve = \input ->
        allBits = Str.trim input |> Binary.hexToBits |> Result.withDefault []

        # consumers
        consumeBits = \bits, n ->
            { value: Binary.listToNat (List.takeFirst bits n) |> Result.withDefault 0, remain: RichList.dropFirst bits n }

        consumeLiteral = \bits, initial ->
            res = consumeBits (List.dropFirst bits) 4
            v = Num.shiftLeftBy initial 4 + res.value
            when bits is
                [0, ..] -> { value: v, remain: res.remain }
                _ -> consumeLiteral res.remain v

        consumeOperator = \bits, collect, collectLiteral ->

            consumeSubpacket = \state ->
                sub = consumePacket state.remain collect collectLiteral
                { subs: List.append state.subs sub.value, remain: sub.remain }

            when bits is
                [0, ..] ->
                    length = consumeBits (List.dropFirst bits) 15
                    subPacketsBits = List.takeFirst length.remain length.value
                    stop = \state -> List.isEmpty state.remain
                    finalState = Func.repeatUntil consumeSubpacket stop { subs: [], remain: subPacketsBits }
                    { finalState & remain: RichList.dropFirst length.remain length.value }

                _ ->
                    length = consumeBits (List.dropFirst bits) 11
                    Func.repeat consumeSubpacket length.value { subs: [], remain: length.remain }

        consumePacket = \bits, collect, collectLiteral ->
            version = consumeBits bits 3
            packetType = consumeBits version.remain 3
            when packetType.value is
                4 ->
                    lit = consumeLiteral packetType.remain 0
                    collected = collect packetType.value version.value [collectLiteral lit.value]
                    { value: collected, remain: lit.remain }

                _ ->
                    subPackets = consumeOperator packetType.remain collect collectLiteral
                    collected = collect packetType.value version.value subPackets.subs
                    { value: collected, remain: subPackets.remain }

        ans1 =
            collect = \_, version, values ->
                version + List.sum values
            res = consumePacket allBits collect (\_ -> 0)
            res.value |> Num.toStr

        ans2 =
            collect = \operation, _, values ->
                when { op: operation, vals: values } is
                    { op: 0, vals: _ } -> List.sum values
                    { op: 1, vals: _ } -> List.product values
                    { op: 2, vals: _ } -> List.min values |> Result.withDefault 0
                    { op: 3, vals: _ } -> List.max values |> Result.withDefault 0
                    { op: 4, vals: [single] } -> single
                    { op: 5, vals: [x, y] } -> if x > y then 1 else 0
                    { op: 6, vals: [x, y] } -> if x < y then 1 else 0
                    { op: 7, vals: [x, y] } -> if x == y then 1 else 0
                    _ -> 0

            res = consumePacket allBits collect Func.identity
            res.value |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/16.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
