import lists
from strutils import parseInt, replace, isDigit
import strformat
import options
from system import newException
import token

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
    return lex.current >= lex.source.len

proc advance(lex: var Lexer): char {.discardable.} =
    lex.current.inc()
    return lex.source[lex.current-1]

proc peek(lex: var Lexer): char =
    return if lex.isAtEOF(): '\0' else: lex.source[lex.current]

proc peekNext(lex: var Lexer): char =
    return if lex.current + 1 >= lex.source.len: '\0' else: lex.source[lex.current+1]

proc match(lex: var Lexer, expected: char): bool =
    if lex.isAtEOF() or lex.source[lex.current] != expected:
        result = false
    else:
        result = true
        lex.current.inc()

template addToken(lex: var Lexer, tkKind: TokenKind) =
    # Add token along with metadata
    lex.tokens.append(
            Token(
                kind: tkKind,
                lexeme: lex.source[lex.start..lex.current-1]
        )
    )

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
        of '>':
            lex.addToken(if lex.match('='): tkGE else: tkGT)
        of '<':
            lex.addToken(if lex.match('='): tkLE else: tkLT)
        of '!':
            lex.addToken(if lex.match('='): tkNE else: tkError)
        of '=':
            lex.addToken(if lex.match('='): tkEQ else: tkError)
        else:
            if isDigit(c): # FIXME isDigit is deprecated method
                lex.scanNumber()
            else:
                raise newException(ValueError,
                        &"unexpected token: {lex.source[lex.start..lex.current]}")

proc scanTokens*(lex: var Lexer): SinglyLinkedList[Token] =
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

proc consume*(cur: var SinglyLinkedNode[Token], expected: TokenKind): bool =
    let token = cur[].value[]

    if token.kind == tkError:
        raise newException(ValueError, &"Appear unexpected token: {token}")

    if token.kind != expected:
        return false
    else:
        cur = cur.next
        return true

proc expectNumber*(cur: var SinglyLinkedNode[Token]): string =
    let token = cur[].value[]

    doAssert(token.kind == tkNum, &"token is {token}")

    cur = cur.next
    return token.lexeme

proc expect*(cur: var SinglyLinkedNode[Token], op: TokenKind): string =
    let token = cur[].value[]

    doAssert(token.kind != tkNum, &"token is {token}")
    doAssert token.kind == op

    cur = cur.next
    return token.lexeme
