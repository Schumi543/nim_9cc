import os
import strformat

when isMainModule:
  let argc = paramCount()
  assert(argc == 1)

  echo &"""
  global _main

  section .text
    _main:
  """

  let input: string = commandLineParams()[0]

  echo &"""
      mov rax, {input}
      ret
  """
