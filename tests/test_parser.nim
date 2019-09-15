
import parser
import node, lexer
import lists
import unittest

suite "parser":
    setup:
        let input: string = "12+23"
        var lex = newLexer(input)
        var t = lex.scanTokens()

    test "head is desirable":
        let n: Node = t.exec()
        check true
