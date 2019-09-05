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

  let input: string = commandLineParams()[0]

  var isFirstNum: bool = true
  var line: string = "      "

  for token in tokenize(input, {'+', '*'}):
    if isFirstNum:
      doAssert(not token.issep)
      echo &"      mov rax, {token.token}"
      isFirstNum = false
    else:
      if token.issep:
        doAssert(line == "      ")
        case token.token:
          of "+":
            line &= "add rax, "
          of "*":
            line &= "mov rax, "

      else:
        echo line & token.token
        line = "      "

  echo "  ret"
