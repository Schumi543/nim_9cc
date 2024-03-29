#!/bin/bash
try() {
  input="$1"
  expected="$2"

  ./src/nim_9cc "$input" >./tmp.asm
  # TODO also support ubuntu for CI
  nasm -f macho64 tmp.asm -o tmp.o
  ld tmp.o -o tmp -macosx_version_min 10.13 -lSystem
  ./tmp
  actual="$?"

  if [ "$actual" = "$expected" ]; then
    echo "$input => $actual"
  else
    echo "$expected expected, but got $actual"
    exit 1
  fi
}

try 0 0
try 42 42
try 5+3 8
try '12 + 4' 16
try ' 12 + 34 - 5 ' 41
try '5+6*7' 47
try '5*(9-6)' 15
try '(3+5)/2' 4
try '-1 + 5' 4
try '2 == 2' 1
try ' 3 > 4' 0
echo OK
