app "day18"
    packages { pf: "cli/cli-platform/main.roc" }
    imports [pf.Stdout, pf.Stderr, pf.File, pf.Path, pf.Task, Binary, RichList]
    provides [main] to pf

main =
    solve = \input ->
        lines = input |> Str.trim |> Str.split "\n"

        # These 'snailfish numbers' can be thought of as binary trees with the regular numbers at the leaves.
        # We'll use the array representation of binary trees (like the usual implementation of binary heaps),
        # except it's actually a List of position-value records, storing only the leaves.
        # We keep the order of the records to be the same as what we see in the input, which is the same
        # as in-order traversal. So we can easily refer to the previous/next element.
        #
        # Parsing the string into this tree format can be done as walking from left to right.
        # Start the position at 1.
        # Every time we see a '[', we're going down one level, so multiply the counter by 2.
        # A ',' means going the the right in the same level, so add the counter by 1.
        # A '[' means going back up the tree, so divide the counter by 2.
        parseTree = \line ->
            Str.graphemes line
            |> List.walk { tree: [], pos: 1 } \state, c ->
                when c is
                    "[" -> { state & pos: state.pos * 2 }
                    "]" -> { state & pos: state.pos // 2 }
                    "," -> { state & pos: state.pos + 1 }
                    _ ->
                        num = Str.toU8 c |> Result.withDefault 0
                        { state & tree: List.append state.tree { pos: state.pos, v: num } }
            |> .tree

        # Adding two snailfish numbers is equivalent to putting the two trees as children of a new root.
        # Looking at any position number in binary, we start with a 1, then a 0 means going down to the left child,
        # a 1 means going down to the right child.
        # So, to make tree into a left child, we insert (in binary) a new 0 after the initial 1 for every positions.
        # TO make the right child we insert a 1, which is the same as just prepending the binary representation with another 1.
        addTree = \t1, t2 ->
            nt1 = List.map t1 \e ->
                pos =
                    Binary.numToBits e.pos
                    |> List.dropFirst
                    |> List.prepend 0
                    |> List.prepend 1
                    |> Binary.listToNat
                    |> Result.withDefault 0
                { e & pos: pos }
            nt2 = List.map t2 \e ->
                pos =
                    Binary.numToBits e.pos
                    |> List.prepend 1
                    |> Binary.listToNat
                    |> Result.withDefault 0
                { e & pos: pos }
            List.concat nt1 nt2

        # A note clarifying the problem: "you must repeatedly do the first action in this list that applies to the snailfish number"
        # means, we first try to apply the explode step from left to right, until no more explodes can be done, before we can start
        # doing any split. At first I understood it as "doing the first thing you can do from left to right, with explode having
        # higher priority." Which somehow gives the correct result for the small example where they explain every internal step,
        # but fails for the larger examples.
        reduceSplit = \tree, index ->
            if index >= List.len tree then
                tree
            else
                item = List.get tree index |> Result.withDefault { pos: 0, v: 0 }

                if item.v >= 10 then
                    v1 = item.v // 2
                    v2 = item.v - v1
                    sp = List.split tree index
                    spTree =
                        sp.before
                        |> List.append { pos: item.pos * 2, v: v1 }
                        |> List.append { pos: item.pos * 2 + 1, v: v2 }
                        |> List.concat (List.dropFirst sp.others)
                    # If the split value is not in the last level, then it won't trigger a new explode
                    # So we can try the split from the newly created left child.
                    # If it's in the last level it will trigger an explode.
                    if item.pos >= 16 then
                        reduceExplode spTree index
                    else
                        reduceSplit spTree index
                else
                    reduceSplit tree (index + 1)

        reduceExplode = \tree, index ->
            if index >= List.len tree then
                reduceSplit tree 0
            else
                item = List.get tree index |> Result.withDefault { pos: 0, v: 0 }

                if item.pos >= 32 then
                    nextItem = List.get tree (index + 1) |> Result.withDefault { pos: 0, v: 0 }
                    expTree1 =
                        if index == 0 then
                            List.dropFirst tree
                        else
                            tree
                            |> List.get (index - 1)
                            |> Result.map \litem ->
                                List.set tree (index - 1) { litem & v: litem.v + item.v }
                            |> Result.withDefault tree
                            |> List.dropAt index
                    expTree2 =
                        expTree1
                        |> List.get (index + 1)
                        |> Result.map \ritem ->
                            List.set expTree1 (index + 1) { ritem & v: ritem.v + nextItem.v }
                        |> Result.withDefault expTree1
                        |> List.set index { pos: item.pos // 2, v: 0 }
                    nIndex = if index == 0 then 0 else index - 1
                    reduceExplode expTree2 nIndex
                else
                    reduceExplode tree (index + 1)

        # We can calculate the magnitude separately for every regular number, using the binary representation of the position.
        # Since we know a 1 (except the very first) means left child, and 0 means right child, so just
        # turn 0 -> 3, 1 -> 2 and find their product.
        magnitude = \tree ->
            List.map tree \{ pos, v } ->
                Binary.numToBits pos
                |> List.dropFirst
                |> List.map \p -> 3 - Num.toNat p
                |> List.product
                |> Num.mul (Num.toNat v)
            |> List.sum

        addAndReduce = \tree1, tree2 ->
            reduceExplode (addTree tree1 tree2) 0

        trees = lines |> List.map Str.trim |> List.map parseTree

        ans1 =
            reducedSum = trees |> RichList.reduce addAndReduce
            reducedSum |> Result.withDefault [] |> magnitude |> Num.toStr

        # part 2
        ans2 =
            List.walk trees 0 \my, t1 ->
                m3 = List.walk trees 0 \mx, t2 ->
                    if t1 == t2 then
                        mx
                    else
                        m1 = magnitude (addAndReduce t1 t2)
                        m2 = magnitude (addAndReduce t2 t1)
                        List.max [mx, m1, m2] |> Result.withDefault mx
                if m3 > my then m3 else my
            |> Num.toStr

        { ans1, ans2 }

    Path.fromStr "data/18.txt"
    |> File.readUtf8
    |> Task.map solve
    |> Task.attempt \result ->
        when result is
            Ok res ->
                _ <- Task.await (Stdout.line res.ans1)
                Stdout.line res.ans2

            Err _ -> Stderr.line "error!"
