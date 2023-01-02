interface RichList
    exposes [partition]
    imports []

partition : List a, (a -> Bool) -> { whenTrue: List a, whenFalse: List a }
partition = \xs, predicate ->
    List.walk xs { whenTrue: [], whenFalse: [] } \state, x ->
        if (predicate x) then
            { state & whenTrue  : List.append state.whenTrue x }
        else
            { state & whenFalse : List.append state.whenFalse x }
