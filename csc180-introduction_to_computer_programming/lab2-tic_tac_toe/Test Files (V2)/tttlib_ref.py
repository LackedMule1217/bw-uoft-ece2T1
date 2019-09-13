# Embedded file name: /u/support/mathaine/lab_2/tttlib_ref.py


def genBoard():
    return [0,
     0,
     0,
     0,
     0,
     0,
     0,
     0,
     0]


def convBoardStateToStr(x, pos):
    if x == 1:
        return 'X'
    elif x == 2:
        return 'O'
    else:
        return str(pos)


def printBoard(T):
    if len(T) != 9:
        return False
    for i in range(0, len(T)):
        if T[i] != 0 and T[i] != 1 and T[i] != 2:
            return False

    str = ' ' + convBoardStateToStr(T[0], 0) + ' | ' + convBoardStateToStr(T[1], 1) + ' | ' + convBoardStateToStr(T[2], 2)
    print str
    print '---|---|---'
    str = ' ' + convBoardStateToStr(T[3], 3) + ' | ' + convBoardStateToStr(T[4], 4) + ' | ' + convBoardStateToStr(T[5], 5)
    print str
    print '---|---|---'
    str = ' ' + convBoardStateToStr(T[6], 6) + ' | ' + convBoardStateToStr(T[7], 7) + ' | ' + convBoardStateToStr(T[8], 8)
    print str
    return True


def analyzeBoard(t):
    if t[0] == t[1] == t[2] != 0:
        return t[0]
    elif t[3] == t[4] == t[5] != 0:
        return t[3]
    elif t[6] == t[7] == t[8] != 0:
        return t[6]
    elif t[0] == t[3] == t[6] != 0:
        return t[0]
    elif t[1] == t[4] == t[7] != 0:
        return t[1]
    elif t[2] == t[5] == t[8] != 0:
        return t[2]
    elif t[0] == t[4] == t[8] != 0:
        return t[0]
    elif t[2] == t[4] == t[6] != 0:
        return t[2]
    n_opens = reduce(lambda x, y: x + y, map(lambda x: (1 if x == 0 else 0), t))
    if n_opens == 0:
        return 3
    else:
        return 0