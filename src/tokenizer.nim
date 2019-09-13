import lists
from strutils import parseInt, replace, isDigit
import strformat
import options
from system import newException

type TokenKind* = enum
    tkPlus
    tkMinus
    tkStar
    tkSlash
    tkNum
    tkParenthesisL
    tkParenthesisR

type Token* = ref object of RootObj
    kind: TokenKind
    str*: Option[string] # accessible for test

const
    Whitespace* = {' ', '\t', '\v', '\r', '\l', '\f'}
iterator tokenize(s: string, seps: set[char] = Whitespace): tuple[
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
            return tkParenthesisL
        of ")":
            return tkParenthesisR
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

proc expect*(cur: var SinglyLinkedNode[Token], op: TokenKind): string =
    let token = cur[].value[]

    doAssert(token.kind != tkNum, &"token is {token}")
    doAssert token.kind == op

    cur = cur.next
    return token.str.get

proc at_eof*(cur: SinglyLinkedNode): bool =
    let token = cur[].value[]
    return token.next.isNil
