import unittest
import options
import lists
import nim_9ccpkg/token

import nim_9ccpkg/lexer

suite "lexer":
    setup:
        let input = "12*20+10"
        var lex = newLexer(input)

    test "":
        let tks: SinglyLinkedList[Token] = lex.scanTokens
        echo tks
