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
        check t.head[].value[].lexeme == some("12")

suite "tokenize(iterator)":
    test "":
        let input = "12*20+10"
        let seps = {'*', '+'}

        var tokenized_input: seq[tuple[token: string, isSep: bool]] = @[]
        for word in tokenize(input, seps):
            tokenized_input.add(word)
        check tokenized_input == @[(token: "12", isSep: false),
         (token: "*", isSep: true), (token: "20", isSep: false),
          (token: "+", isSep: true), (token: "10", isSep: false)]

    test "":
        let input = "12>=20+10"
        let seps = {"+"}

        var tokenized_input: seq[tuple[token: string, isSep: bool]] = @[]
        for word in tokenize(input, seps):
            tokenized_input.add(word)
        check tokenized_input == @[(token: "12", isSep: false),
         (token: "*", isSep: true), (token: "20", isSep: false),
          (token: "+", isSep: true), (token: "10", isSep: false)]
