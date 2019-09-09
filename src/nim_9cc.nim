import os
import strformat
import strutils
from tokenizer import tokenize, at_eof, expect_number, expect, consume, Token
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

  let simbol = {'+', '-'}
  let tokenized_input: SinglyLinkedList[Token] = tokenize(input, simbol)
  var cur: SinglyLinkedNode[Token] = tokenized_input.head

  echo &"      mov rax, {expect_number(cur)}"

  while not cur.isNil:
    if consume(cur, "+"):
      echo &"      add rax, {expect_number(cur)}"
    elif consume(cur, "-"):
      echo &"      sub rax, {expect_number(cur)}"
    else: doAssert(false, &"token is unexpected: {cur[].value[]}")

  echo "  ret"
