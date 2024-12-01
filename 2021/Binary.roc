interface Binary
    exposes [
        strToNat,
        listToNat,
        hexToBits,
        numToBits,
    ]
    imports []

strToNat : Str -> Result Nat [InvalidBinary]
strToNat = \str ->
    Str.toScalars str
    |> List.map \s -> s - 48
    |> listToNat

listToNat : List (Int *) -> Result Nat [InvalidBinary]
listToNat = \xs ->
    initial : Result Nat [InvalidBinary]
    initial = Ok 0nat
    List.walk xs initial \result, bit ->
        Result.try result \n ->
            when bit is
                0 -> Ok (n * 2)
                1 -> Ok (n * 2 + 1)
                _ -> Err InvalidBinary

numToBits : Int * -> List U8 
numToBits = \n ->
    if n <= 1 then [Num.toU8 n]
    else List.append (numToBits (n // 2)) (Num.toU8 (n % 2))

hexToBits : Str -> Result (List U8) [InvalidBinary]
hexToBits = \hexstring ->
    initial : Result (List U8) [InvalidBinary]
    initial = Ok []
    Str.graphemes hexstring
    |> List.walk initial \result, hex ->
        Result.try result \xs ->
            when hex is
                "0" -> Ok (List.concat xs [0, 0, 0, 0])
                "1" -> Ok (List.concat xs [0, 0, 0, 1])
                "2" -> Ok (List.concat xs [0, 0, 1, 0])
                "3" -> Ok (List.concat xs [0, 0, 1, 1])
                "4" -> Ok (List.concat xs [0, 1, 0, 0])
                "5" -> Ok (List.concat xs [0, 1, 0, 1])
                "6" -> Ok (List.concat xs [0, 1, 1, 0])
                "7" -> Ok (List.concat xs [0, 1, 1, 1])
                "8" -> Ok (List.concat xs [1, 0, 0, 0])
                "9" -> Ok (List.concat xs [1, 0, 0, 1])
                "A" -> Ok (List.concat xs [1, 0, 1, 0])
                "B" -> Ok (List.concat xs [1, 0, 1, 1])
                "C" -> Ok (List.concat xs [1, 1, 0, 0])
                "D" -> Ok (List.concat xs [1, 1, 0, 1])
                "E" -> Ok (List.concat xs [1, 1, 1, 0])
                "F" -> Ok (List.concat xs [1, 1, 1, 1])
                _ -> Err InvalidBinary
