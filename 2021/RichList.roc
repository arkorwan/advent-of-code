interface RichList
    exposes [
        partition,
        frequency,
        bestBy,
        minBy,
        maxBy,
        dropFirst,
        reduce,
    ]
    imports []

partition : List a, (a -> Bool) -> { whenTrue : List a, whenFalse : List a }
partition = \xs, predicate ->
    List.walk xs { whenTrue: [], whenFalse: [] } \state, x ->
        if predicate x then
            { state & whenTrue: List.append state.whenTrue x }
        else
            { state & whenFalse: List.append state.whenFalse x }

frequency : List a, Dict a (Int b) -> Dict a (Int b)
frequency = \xs, start ->
    increment = \dict, key ->
        Dict.update dict key \current ->
            when current is
                Missing -> Present 1
                Present x -> Present (x + 1)
    List.walk xs start increment

bestBy : List a, (a -> b), (b, b -> Bool) -> Result a [ListWasEmpty]
bestBy = \xs, mapper, comparator ->
    List.first xs
    |> Result.map \head ->
        best =
            List.dropFirst xs
            |>
            List.walk { score: mapper head, element: head } \state, item ->
                itemScore = mapper item
                if comparator itemScore state.score then
                    { score: itemScore, element: item }
                else
                    state
        best.element

minBy : List a, (a -> Num b) -> Result a [ListWasEmpty]
minBy = \xs, mapper -> bestBy xs mapper (\x, y -> x < y)

maxBy : List a, (a -> Num b) -> Result a [ListWasEmpty]
maxBy = \xs, mapper -> bestBy xs mapper (\x, y -> x > y)

dropFirst : List a, Nat -> List a
dropFirst = \xs, n ->
    l = List.len xs
    List.takeLast xs (l - n)

reduce : List a, (a, a -> a) -> Result a [ListWasEmpty]
reduce = \xs, reducer ->
    when xs is
        [] -> Err ListWasEmpty
        [head, ..] -> Ok (List.walk (List.dropFirst xs) head reducer)