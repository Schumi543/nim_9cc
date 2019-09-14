
import parser
import lists
import lexer
import unittest

suite "parser":
    setup:
        let input: string = "12+23"
        var lex = newLexer(input)
        var t = lex.scanTokens()
        let node = expr(t.head)

    test "head is desirable":
        gen(node)
        check true
