import lists
from strutils import tokenize, parseInt, replace, isDigit
import strformat
import options
from system import newException

type TokenKind* = enum
    tkPlus
    tkMinus
    tkStar
    tkSlash
    tkNum
    tkParethesisL
    tkParethesisR

type Token* = ref object of RootObj
    kind: TokenKind
    str*: Option[string] # accessible for test


proc judge_token_kind(s: string): TokenKind =
    case s:
        of "+":
            return tkPlus
        of "-":
            return tkMinus
        of "*":
            return tkStar
        of "/":
            return tkSlash
        of "(":
            return tkParethesisL
        of ")":
            return tkParethesisR
        else:
            if isDigit(s): # FIXME isDigit is deprecated method
                return tkNum
            else:
                raise newException(ValueError, &"unexpected token: {s}")

proc new_token(isSep: bool, str: string): Token =
    return Token(kind: judge_token_kind(str), str: some(str))


proc tokenize*(input: string, simbols: set[char]): SinglyLinkedList[Token] =
    let trimmed_input = input.replace(" ", "")
    var ret = initSinglyLinkedList[Token]()
    for token in tokenize(trimmed_input, simbols):
        var t = new_token(token.isSep, token.token)
        var cur = newSinglyLinkedNode[Token](t)
        ret.append(cur)

    return ret


proc consume*(cur: var SinglyLinkedNode[Token], expected: TokenKind): bool =
    let token = cur[].value[]

    if token.kind != expected:
        return false
    else:
        cur = cur.next
        return true

proc expect_number*(cur: var SinglyLinkedNode[Token]): string =
    let token = cur[].value[]

    doAssert(token.kind == tkNum, &"token is {token}")

    cur = cur.next
    return token.str.get

proc expect*(cur: var SinglyLinkedNode[Token], op: string): string =
    let token = cur[].value[]

    echo token

    doAssert(token.kind != tkNum, &"token is {token}")
    doAssert token.str.get == op

    cur = cur.next
    return token.str.get

proc at_eof*(cur: SinglyLinkedNode): bool =
    let token = cur[].value[]
    return token.next.isNil
