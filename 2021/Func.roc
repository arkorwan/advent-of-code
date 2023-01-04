interface Func
    exposes [
        repeat
        ]
    imports []

repeat : (a -> a), Nat, a -> a 
repeat = \func, n, init ->
    if n == 0 then init
    else repeat func (n-1) (func init)