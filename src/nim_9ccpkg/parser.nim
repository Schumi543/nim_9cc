import lexer
import strformat
from strutils import parseInt, indent
import lists
import token, node

#[
EBNF

expr       = equality
equality   = relational ("==" relational | "!=" relational)*
relational = add ("<" add | "<=" add | ">" add | ">=" add)*
add        = mul ("+" mul | "-" mul)*
mul        = unary ("*" unary | "/" unary)*
unary      = ("+" | "-")? primary
primary    = num | "(" expr ")"
]#

proc expr*(cur: var SinglyLinkedNode[Token]): Node
proc equality(cur: var SinglyLinkedNode[Token]): Node
proc relational(cur: var SinglyLinkedNode[Token]): Node
proc add(cur: var SinglyLinkedNode[Token]): Node
proc mul(cur: var SinglyLinkedNode[Token]): Node
proc unary(cur: var SinglyLinkedNode[Token]): Node
proc primary(cur: var SinglyLinkedNode[Token]): Node

proc exec*(tokens: SinglyLinkedList[Token]): Node =
  var cur: SinglyLinkedNode[Token] = tokens.head
  return cur.expr()

proc expr(cur: var SinglyLinkedNode[Token]): Node =
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
