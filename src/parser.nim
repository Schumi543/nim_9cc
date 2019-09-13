from tokenizer import consume, expect, expect_number, Token, TokenKind
import strformat
from strutils import parseInt, indent
import lists

type NodeKind = enum
  ndAdd
  ndSub
  ndMul # mul is proc
  ndDiv # div is keyword
  ndNum

type Node = ref object of RootObj
  kind: NodeKind
  lhs: Node
  rhs: Node
  num: int

proc mul(cur: var SinglyLinkedNode[Token]): Node
proc expr*(cur: var SinglyLinkedNode[Token]): Node
proc primary(cur: var SinglyLinkedNode[Token]): Node
proc unary(cur: var SinglyLinkedNode[Token]): Node

proc unary(cur: var SinglyLinkedNode[Token]): Node =
  if cur.consume(tkPlus):
    return cur.primary()
  if cur.consume(tkMinus):
    return Node(kind: ndSub, lhs: Node(kind: ndNum, num: 0), rhs: cur.primary()) # 0 - x
  return cur.primary()

proc expr*(cur: var SinglyLinkedNode[Token]): Node =
  var node = cur.mul() # 1, consume 12

  while not cur.isNil:
    if cur.consume(tkPlus): # 2. consume +
      node = Node(kind: ndAdd, lhs: node, rhs: cur.mul()) # 3 consume23 node = 12 + 23 #4 node = (12+23) +34
    elif cur.consume(tkMinus):
      node = Node(kind: ndSub, lhs: node, rhs: cur.mul())
    else:
      return node

  return node

proc mul(cur: var SinglyLinkedNode[Token]): Node =
  var node = cur.unary()

  while not cur.isNil:
    if cur.consume(tkStar):
      node = Node(kind: ndMul, lhs: node, rhs: cur.unary())
    elif cur.consume(tkSlash):
      node = Node(kind: ndDiv, lhs: node, rhs: cur.unary())
    else:
      return node

  return node

proc primary(cur: var SinglyLinkedNode[Token]): Node =
  if cur.consume(tkParenthesisL):
    result = cur.expr()
    doAssert cur.consume(tkParenthesisR)
  else:
    result = Node(kind: ndNum, num: cur.expect_number().parseInt())


proc gen*(node: Node): void =
  if node.kind == ndNum:
    echo (&"push {node.num}").indent(6)

  if not node.lhs.isNil:
    gen(node.lhs)
  else: return

  if not node.rhs.isNil:
    gen(node.rhs)
  else: return

  echo "pop rdi".indent(6)
  echo "pop rax".indent(6)

  case node.kind:
    of ndAdd:
      echo "add rax, rdi".indent(6)
    of ndSub:
      echo "sub rax, rdi".indent(6)
    of ndMul:
      echo "imul rax, rdi".indent(6)
    of ndDiv:
      echo "cqo".indent(6)
      echo "idiv rdi".indent(6)
    of ndNum:
      echo ""

  echo "push rax".indent(6)
