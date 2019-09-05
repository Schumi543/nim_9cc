import os
import strformat
import strutils

when isMainModule:
  let argc = paramCount()
  assert(argc == 1)

  echo &"""
  global _main

  section .text
    _main:
  """

  let input: string = commandLineParams()[0].replace(" ", "")

  var isFirstNum: bool = true
  var line: string = "      "

  for token in tokenize(input, {'+', '-'}):
    if isFirstNum:
      doAssert(not token.issep, "input must start with Num")
      echo &"      mov rax, {token.token}"
      isFirstNum = false
    else:
      if token.issep:
        doAssert(line == "      ", &"line is invalid: {line}, there maybe more than two sequential operators in input")
        case token.token:
          of "+":
            line &= "add rax, "
          of "-":
            line &= "sub rax, "

      else:
        doAssert(token.token.isDigit, &"expect digit, but got {token.token}")
        echo line & token.token
        line = "      "

  echo "  ret"
