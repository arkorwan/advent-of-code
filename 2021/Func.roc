interface Func
    exposes [
        identity,
        repeat,
        repeatUntil,
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
