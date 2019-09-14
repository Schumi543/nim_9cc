import tokenizer
import unittest
import options

suite "tokenize":
    setup:
        let input = "12+23+34"
        let seps = {'+'}

    test "head is desirable":
        let t = tokenizer.tokenize(input, seps)

        # check t.head[].value of
        check t.head[].value[].str == some("12")
