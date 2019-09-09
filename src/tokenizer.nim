import lists
from strutils import tokenize, parseInt, replace
import strformat
import options

type TokenKind = enum
    Reserved
    Num

type Token* = ref object of RootObj
    kind: TokenKind
    str*: Option[string] # accessible for test


proc new_token(isSep: bool, str: string): Token =
    return Token(kind: if isSep: Reserved else: Num, str: some(str))


proc tokenize*(input: string, simbols: set[char]): SinglyLinkedList[Token] =
    let trimmed_input = input.replace(" ", "")
    var ret = initSinglyLinkedList[Token]()
    for token in tokenize(trimmed_input, simbols):
        var t = new_token(token.isSep, token.token)
        var cur = newSinglyLinkedNode[Token](t)
        ret.append(cur)

    return ret


proc consume*(cur: var SinglyLinkedNode[Token], expected: string): bool =
    let token = cur[].value[]

    if token.kind != Reserved or token.str.get != expected:
        return false
    else:
        cur = cur.next
        return true

proc expect_number*(cur: var SinglyLinkedNode[Token]): string =
    let token = cur[].value[]

    doAssert(token.kind == Num, &"token is {token}")

    cur = cur.next
    return token.str.get

proc expect*(cur: var SinglyLinkedNode[Token], op: string): string =
    let token = cur[].value[]

    echo token

    doAssert(token.kind == Reserved, &"token is {token}")
    doAssert token.str.get == op

    cur = cur.next
    return token.str.get

proc at_eof*(cur: SinglyLinkedNode): bool =
    let token = cur[].value[]
    return token.next.isNil
