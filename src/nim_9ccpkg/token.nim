import strformat

type TokenKind* = enum
    tkPlus         # +
    tkMinus        # -
    tkStar         # *
    tkSlash        # /
    tkParenthesisL # (
    tkParenthesisR # )
    tkEQ           # ==
    tkNE           # !=
    tkLT           # <
    tkLE           # <=
    tkGT           # >
    tkGE           # >=
    tkNum
    tkEOF
    tkError        # for handle Error

type Token* = ref object of RootObj
    kind*: TokenKind
    lexeme*: string

proc `$`*(tk: Token): string =
    return &"[kind: {tk.kind}, lexeme: {tk.lexeme}]"
