import os
import strformat

when isMainModule:
  let argc = paramCount()
  let argv = commandLineParams()

  assert(argc == 1)

  echo(".intel_syntax noprefix");
  echo(".global main");
  echo("main:");
  echo(&"  mov rax, {argv[0]}");
  echo("  ret");
