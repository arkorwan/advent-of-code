interface Binary
    exposes [strToNat, listToNat]
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
