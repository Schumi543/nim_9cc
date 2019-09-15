type NodeKind* = enum
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

type Node* = ref object of RootObj
  kind*: NodeKind
  lhs*: Node
  rhs*: Node
  num*: int
