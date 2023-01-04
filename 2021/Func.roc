interface Func
    exposes [
        identity,
        repeat,
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
