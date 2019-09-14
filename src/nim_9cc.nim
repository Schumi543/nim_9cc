import os
import strformat
import strutils
import tokenkind
from tokenizer import tokenize, at_eof, expect_number, expect, consume, Token
from parser import gen, expr
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

  let simbol = {'+', '-', '*', '/', '(', ')'}
  let tokenized_input: SinglyLinkedList[Token] = tokenize(input, simbol)
  var cur: SinglyLinkedNode[Token] = tokenized_input.head

  let node = expr(cur)
  node.gen()

  echo "pop rax".indent(6)
  echo "ret".indent(2)
