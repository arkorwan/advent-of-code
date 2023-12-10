# comparator for sorting seqs lexicographically
func lexicographic*[T](x, y: seq[T]): int =
    if x.len == 0 or y.len == 0:
        x.len - y.len
    elif x[0] == y[0]:
        lexicographic(x[1..^1], y[1..^1])
    else:
        cmp(x[0], y[0])
