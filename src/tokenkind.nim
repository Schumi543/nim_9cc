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
