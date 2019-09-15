from strutils import indent
import strformat
import node

proc gen*(node: Node): void

proc exec*(node: Node): void =
    echo &"""
  global _main
  
  section .text
      _main:
    """

    gen(node)

    echo "pop rax".indent(6)
    echo "ret".indent(2)

proc gen(node: Node): void =

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
