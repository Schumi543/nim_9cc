import TokenKind
import strformat

type Token* = ref object of RootObj
    kind*: TokenKind
    lexeme*: string

proc `$`*(tk: Token): string =
    return &"[kind: {tk.kind}, lexeme: {tk.lexeme}]"
