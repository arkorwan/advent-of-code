interface RichList
    exposes [
        partition,
        bestBy,
        minBy,
        maxBy
        ]
    imports []

partition : List a, (a -> Bool) -> { whenTrue: List a, whenFalse: List a }
partition = \xs, predicate ->
    List.walk xs { whenTrue: [], whenFalse: [] } \state, x ->
        if (predicate x) then
            { state & whenTrue  : List.append state.whenTrue x }
        else
            { state & whenFalse : List.append state.whenFalse x }

bestBy : List a, (a -> b), (b, b -> Bool)  -> Result a [ListWasEmpty]
bestBy = \xs, mapper, comparator ->
    List.first xs |> Result.map \head ->
        best = List.dropFirst xs |>
            List.walk { score: mapper head, element: head} \state, item ->
                itemScore = mapper item
                if comparator itemScore state.score then
                    { score: itemScore, element: item }
                else state
        best.element

minBy : List a, (a -> (Num b)) -> Result a [ListWasEmpty]
minBy = \xs, mapper -> bestBy xs mapper (\x, y -> x < y)

maxBy : List a, (a -> (Num b)) -> Result a [ListWasEmpty]
maxBy = \xs, mapper -> bestBy xs mapper (\x, y -> x > y)