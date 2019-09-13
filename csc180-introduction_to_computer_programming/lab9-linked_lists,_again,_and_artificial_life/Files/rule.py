def rule(value, list):
    try:
        if value == 1:
            if (sum(list) == 2) or (sum(list) == 3):
                return 1
            else:
                return 0
        else:
            if sum(list) == 3:
                return 1
            else:
                return 0
    except:
        return False
