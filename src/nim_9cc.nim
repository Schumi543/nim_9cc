import os
import strutils
import nim_9ccpkg/lexer, nim_9ccpkg/parser, nim_9ccpkg/codegen,
    nim_9ccpkg/token
import lists

when isMainModule:
  let argc = paramCount()
  doAssert(argc == 1)

  let input: string = commandLineParams()[0].replace(" ", "")
  var lex = newLexer(input)

  let tokens: SinglyLinkedList[Token] = lex.scanTokens()
  let node = parser.exec(tokens)
  node.exec()
