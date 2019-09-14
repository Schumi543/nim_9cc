import tokenizer
import unittest
import options
import lists

suite "lexer":
    setup:
        let input = "12*20+10"
        var lex = tokenizer.newLexer(input)

    test "":
        let tks: SinglyLinkedList[Token] = lex.scanTokens
        echo tks
