
import lists
import unittest
import nim_9ccpkg/node, nim_9ccpkg/lexer

import nim_9ccpkg/parser

suite "parser":
    setup:
        let input: string = "12+23"
        var lex = newLexer(input)
        var t = lex.scanTokens()

    test "head is desirable":
        let n: Node = t.exec()
        check true
