interface Func
    exposes [
        identity,
        repeat,
        repeatUntil,
        takeUntil,
    ]
    imports []

identity : a -> a
identity = \x -> x

repeat : (a -> a), Nat, a -> a
repeat = \func, n, state ->
    if n == 0 then
        state
    else
        repeat func (n - 1) (func state)

repeatUntil : (a -> a), (a -> Bool), a -> a
repeatUntil = \func, condition, state ->
    if condition state then
        state
    else
        repeatUntil func condition (func state)

takeUntil : (a -> a), (a -> Bool), a -> List a
takeUntil = \func, condition, state ->
    recur = \history, current ->
        if condition current then
            history
        else
            recur (List.append history current) (func current)
    recur [] state