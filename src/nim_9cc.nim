import os
import strformat
import strutils
import token
import lexer, parser, codegen
import lists

when isMainModule:
  let argc = paramCount()
  doAssert(argc == 1)

  let input: string = commandLineParams()[0].replace(" ", "")
  var lex = newLexer(input)

  let tokens: SinglyLinkedList[Token] = lex.scanTokens()
  let node = parser.exec(tokens)
  node.exec()
