def genBoard():
    return [0, 0, 0, 0, 0, 0, 0, 0, 0]



def printBoard(T):
    list = [i for i in range(9)]
    try:
        assert len(T) == 9
        for i in T:
            assert i >= 0 and i <=2
            assert type(i) == int

        for i in range(9):
            if T[i] == 0:
                list[i] = i
            elif T[i] == 1:
                list[i] = "X"
            elif T[i] == 2:
                list[i] = "O"
            else:
                assert 1 == 2

        print(" {} | {} | {} ".format(list[0], list[1], list[2]))
        print("---|---|---")
        print(" {} | {} | {} ".format(list[3], list[4], list[5]))
        print("---|---|---")
        print(" {} | {} | {} ".format(list[6], list[7], list[8]))

        return True

    except:
        return False



def analyzeBoard(T):
    try:
        assert len(T) == 9
        for i in T:
            assert i >= 0 and i <=2
            assert type(i) == int

        # Horizontal
        for i in range(0,9,3):
            if T[i] == T[i + 1] == T[i + 2] == 1:
                return 1
            if T[i] == T[i + 1] == T[i + 2] == 2:
                return 2
        # Vertical
        for i in range(0,3):
            if T[i] == T[i + 3] == T[i + 6] == 1:
                return 1
            if T[i] == T[i + 3] == T[i + 6] == 2:
                return 2
        # Diagonal
        if (T[0] == T[4] == T[8] or T[2] == T[4] == T[6]) and T[4] == 1:
            return 1
        if (T[0] == T[4] == T[8] or T[2] == T[4] == T[6]) and T[4] == 2:
            return 2

        if all(T[i] != 0 for i in range(9)):
            return 3

        return 0

    except:
        return -1



def genRandomMove(T, player):
    from random import randint

    try:
        assert len(T) == 9
        assert player == 1 or player == 2
        for i in T:
            assert i >= 0 and i <=2
            assert type(i) == int
        if all(T[i] != 0 for i in range(len(T))):
            assert 1 == 2

        while True:
            num = randint(0,8)

            if T[num] == 0:
                return num
            else:
                continue

    except:
        return -1



def genWinningMove(T, player):
    try:
        assert len(T) == 9
        assert player == 1 or player == 2
        for i in T:
            assert i >= 0 and i <=2
            assert type(i) == int
        if all(T[i] != 0 for i in range(len(T))):
            assert 1 == 2

        # Horizontal
        for i in range(0,9,3):
            if (T[i] == T[i + 1] == player) and T[i + 2] == 0:
                return i + 2
            if (T[i] == T[i + 2] == player) and T[i + 1] == 0:
                return i + 1
            if (T[i + 1] == T[i + 2] == player) and T[i] == 0:
                return i
        # Vertical
        for i in range(0,3):
            if (T[i] == T[i + 3] == player) and T[i + 6] == 0:
                return 1 + 6
            if (T[i] == T[i + 6] == player) and T[i + 3] == 0:
                return 1 + 3
            if (T[i + 3] == T[i + 6] == player) and T[i] == 0:
                return 1

        # Diagonal
        if (T[0] == T[4] == player) and T[8] == 0:
            return 8
        if (T[0] == T[8] == player) and T[4] == 0:
            return 4
        if (T[4] == T[8] == player) and T[0] == 0:
            return 0
        if (T[2] == T[4] == player) and T[6] == 0:
            return 6
        if (T[2] == T[6] == player) and T[4] == 0:
            return 4
        if (T[4] == T[6] == player) and T[2] == 0:
            return 2

    except:
        return -1



def genNonLoser(T, player):
    try:
        assert len(T) == 9
        assert player == 1 or player == 2
        for i in T:
            assert i >= 0 and i <=2
            assert type(i) == int
        if all(T[i] != 0 for i in range(len(T))):
            assert 1 == 2

        # Horizontal
        for i in range(0,9,3):
            if (T[i] == T[i + 1] != player != 0) and T[i + 2] == 0:
                return i + 2
            if (T[i] == T[i + 2] != player != 0) and T[i + 1] == 0:
                return i + 1
            if (T[i + 1] == T[i + 2] != player != 0) and T[i] == 0:
                return i
        # Vertical
        for i in range(0,3):
            if (T[i] == T[i + 3] != player != 0) and T[i + 6] == 0:
                return 1 + 6
            if (T[i] == T[i + 6] != player != 0) and T[i + 3] == 0:
                return 1 + 3
            if (T[i + 3] == T[i + 6] != player != 0) and T[i] == 0:
                return 1

        # Diagonal
        if (T[0] == T[4] != player != 0) and T[8] == 0:
            return 8
        if (T[0] == T[8] != player != 0) and T[4] == 0:
            return 4
        if (T[4] == T[8] != player != 0) and T[0] == 0:
            return 0
        if (T[2] == T[4] != player != 0) and T[6] == 0:
            return 6
        if (T[2] == T[6] != player != 0) and T[4] == 0:
            return 4
        if (T[4] == T[6] != player != 0) and T[2] == 0:
            return 2

    except:
        return -1
