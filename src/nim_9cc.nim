import os
import strformat

when isMainModule:
  let argc = paramCount()
  let argv = commandLineParams()

  assert(argc == 1)

  echo &"""
  global _main

  section .text
    _main:
      mov rax, {argv[0]}
      ret
  """
