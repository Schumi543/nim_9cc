import lists
from strutils import parseInt, replace, isDigit
import strformat
import options
from system import newException
import tokenkind

type Token* = ref object of RootObj
    kind: TokenKind
    lexeme*: string # accessible for test

proc `$`*(tk: Token): string =
    return &"[kind: {tk.kind}, lexeme: {tk.lexeme}]"

type Lexer = ref object of RootObj
    source: string
    tokens: SinglyLinkedList[Token]
    start, current: int

proc newLexer*(source: string): Lexer =
    # Create a new Lexer instance
    return Lexer(
        source: source,
        start: 0,
        current: 0,
    )

proc isAtEOF(lex: Lexer): bool =
    # Check if EOF reached
    return lex.current >= lex.source.len

proc advance(lex: var Lexer): char {.discardable.} =
    # increment current
    lex.current.inc()
    return lex.source[lex.current-1]

proc peek(lex: var Lexer): char =
    # Returns the current char without moving to the next one
    return if lex.isAtEOF(): '\0' else: lex.source[lex.current]

proc peekNext(lex: var Lexer): char =
    return if lex.current + 1 >= lex.source.len: '\0' else: lex.source[lex.current+1]

proc match(lex: var Lexer, expected: char): bool =
    result = true
    if lex.isAtEOF() or lex.source[lex.current] != expected:
        result = false
    else:
        # Match found and increment position.
        # Group current & previous chars into a single tokenKind
        lex.current.inc()

template addToken(lex: var Lexer, tkKind: TokenKind) =
    # Add token along with metadata
    lex.tokens.append(
            Token(
                kind: tkKind,
                lexeme: lex.source[lex.start..lex.current-1]
        )
    )

const
    Whitespace* = {' ', '\t', '\v', '\r', '\l', '\f'}
iterator tokenize*(s: string, seps: set[char] = Whitespace): tuple[
    token: string, isSep: bool] =
    var i = 0
    while true:
        var j = 0
        var isSep = i+j < s.len and s[i+j] in seps
        while i+j < s.len and (s[i+j] in seps) == isSep and (if isSep and j >
                0: s[i+j] == s[i+j-1] else: true): inc(j)
        if j > 0:
            yield (substr(s, i, i+j-1), isSep)
        else:
            break
        i += j

proc scanNumber(lex: var Lexer) =
    while isDigit(lex.peek()): lex.advance()
    if lex.peek() == '.' and isDigit(lex.peekNext()):
        lex.advance()
        while isDigit(lex.peek()): lex.advance()
    lex.addToken(tkNum)

proc scanToken(lex: var Lexer): TokenKind {.discardable.} =
    let c: char = lex.advance()
    case c:
        of '+':
            lex.addToken(tkPlus)
        of '-':
            lex.addToken(tkMinus)
        of '*':
            lex.addToken(tkStar)
        of '/':
            lex.addToken(tkSlash)
        of '(':
            lex.addToken(tkParenthesisL)
        of ')':
            lex.addToken(tkParenthesisR)
        else:
            if isDigit(c): # FIXME isDigit is deprecated method
                lex.scanNumber()
            else:
                raise newException(ValueError,
                        &"unexpected token: {lex.source[lex.start..lex.current]}")

proc scanTokens*(lex: var Lexer): SinglyLinkedList[Token] =
    # ScanTokens keeps scanning the source code untils it find the EOF delimiter.
    # It returns a seq of tokens that represents the entire source code.
    lex.tokens = initSinglyLinkedList[Token]()
    while not lex.isAtEOF():
        lex.start = lex.current
        lex.scanToken()
    # EOF token
    lex.tokens.append(
      Token(
        kind: tkEof,
        lexeme: ""
        )
    )
    return lex.tokens

# proc newToken(lexeme: string): Token =
#     return Token(kind: scanToken(lexeme), lexeme: lexeme)


# proc tokenize*(input: string, simbols: set[char]): SinglyLinkedList[Token] =
#     let trimmed_input = input.replace(" ", "")
#     var ret = initSinglyLinkedList[Token]()
#     for token in tokenize(trimmed_input, simbols):
#         var t = new_token(token.token)
#         var cur = newSinglyLinkedNode[Token](t)
#         ret.append(cur)

#     return ret


proc consume*(cur: var SinglyLinkedNode[Token], expected: TokenKind): bool =
    let token = cur[].value[]

    if token.kind != expected:
        return false
    else:
        cur = cur.next
        return true

# proc expectNumber*(cur: var SinglyLinkedNode[Token]): string =
#     let token = cur[].value[]

#     doAssert(token.kind == tkNum, &"token is {token}")

#     cur = cur.next
#     return token.lexeme.get

# proc expect*(cur: var SinglyLinkedNode[Token], op: TokenKind): string =
#     let token = cur[].value[]

#     doAssert(token.kind != tkNum, &"token is {token}")
#     doAssert token.kind == op

#     cur = cur.next
#     return token.lexeme.get
