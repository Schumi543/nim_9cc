import os
import strformat

when isMainModule:
  let argc = paramCount()
  let argv = commandLineParams()

  assert(argc == 1)

  echo &"""
  .intel_syntax noprefix
  .global main
  main:
    mov rax, {argv[0]}
    ret
  """
