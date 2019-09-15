import lexer
import strformat
from strutils import parseInt, indent
import lists
import token, tokenkind

type NodeKind = enum
  ndAdd
  ndSub
  ndMul
  ndDiv
  ndNum
  ndEQ # ==
  ndNE # !=
  ndLT # <
  ndLE # <=
  ndGT # >
  ndGE # >=

type Node = ref object of RootObj
  kind: NodeKind
  lhs: Node
  rhs: Node
  num: int

proc expr*(cur: var SinglyLinkedNode[Token]): Node
proc equality(cur: var SinglyLinkedNode[Token]): Node
proc relational(cur: var SinglyLinkedNode[Token]): Node
proc add(cur: var SinglyLinkedNode[Token]): Node
proc mul(cur: var SinglyLinkedNode[Token]): Node
proc unary(cur: var SinglyLinkedNode[Token]): Node
proc primary(cur: var SinglyLinkedNode[Token]): Node

proc expr*(cur: var SinglyLinkedNode[Token]): Node =
  return cur.equality()

proc equality(cur: var SinglyLinkedNode[Token]): Node =
  var node = cur.relational()

  while not cur.isNil:
    if cur.consume(tkEQ):
      node = Node(kind: ndEQ, lhs: node, rhs: cur.relational())
    elif cur.consume(tkNE):
      node = Node(kind: ndNE, lhs: node, rhs: cur.relational())
    else:
      return node

  return node

proc relational(cur: var SinglyLinkedNode[Token]): Node =
  var node = cur.add()

  while not cur.isNil:
    if cur.consume(tkLT):
      node = Node(kind: ndLT, lhs: node, rhs: cur.add())
    elif cur.consume(tkLE):
      node = Node(kind: ndLE, lhs: node, rhs: cur.add())
    elif cur.consume(tkGT):
      node = Node(kind: ndGT, lhs: node, rhs: cur.add())
    elif cur.consume(tkGE):
      node = Node(kind: ndLE, lhs: node, rhs: cur.add())
    else:
      return node

  return node

proc add(cur: var SinglyLinkedNode[Token]): Node =
  var node = cur.mul()

  while not cur.isNil:
    if cur.consume(tkPlus):
      node = Node(kind: ndAdd, lhs: node, rhs: cur.mul())
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

proc unary(cur: var SinglyLinkedNode[Token]): Node =
  if cur.consume(tkPlus):
    return cur.primary()
  if cur.consume(tkMinus):
    return Node(kind: ndSub, lhs: Node(kind: ndNum, num: 0), rhs: cur.primary()) # 0 - x
  return cur.primary()

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
    of ndEQ:
      echo "cmp rax, rdi".indent(6)
      echo "sete al".indent(6)
    of ndNE: # FIXME WET code
      echo "cmp rax, rdi".indent(6)
      echo "setne al".indent(6)
    of ndLT:
      echo "cmp rax, rdi".indent(6)
      echo "setl al".indent(6)
    of ndLE:
      echo "cmp rax, rdi".indent(6)
      echo "setle al".indent(6)
    of ndGT:
      echo "cmp rdi, rax".indent(6)
      echo "setl al".indent(6)
    of ndGE:
      echo "cmp rdi, rax".indent(6)
      echo "setle al".indent(6)
    of ndNum:
      echo ""

  echo "push rax".indent(6)
