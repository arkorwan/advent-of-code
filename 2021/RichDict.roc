interface RichDict
    exposes [
        mapValues,
        merge,
    ]
    imports []

mapValues : Dict a b, (b -> c) -> Dict a c
mapValues = \dict, transform ->
    Dict.walk dict Dict.empty \res, k, v ->
        Dict.insert res k (transform v)

merge : Dict a b, Dict a b, (b, b -> b) -> Dict a b
merge = \dict1, dict2, combine ->
    Dict.walk dict1 dict2 \res, k, v ->
        Dict.update res k \possibleValue ->
            when possibleValue is
                Missing -> Present v
                Present w -> Present (combine w v)
