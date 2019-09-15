import os
import strformat
import strutils
import token
import lexer, codegen
from parser import expr
import lists

when isMainModule:
  let argc = paramCount()
  doAssert(argc == 1)

  echo &"""
  global _main

  section .text
    _main:
  """

  let input: string = commandLineParams()[0].replace(" ", "")
  var lex = newLexer(input)

  let tokenized_input: SinglyLinkedList[Token] = lex.scanTokens()
  var cur: SinglyLinkedNode[Token] = tokenized_input.head

  let node = expr(cur)
  node.gen()

  echo "pop rax".indent(6)
  echo "ret".indent(2)
