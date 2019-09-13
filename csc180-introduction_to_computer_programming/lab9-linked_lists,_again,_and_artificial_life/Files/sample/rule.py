# Embedded file name: /u/support/mathaine/conway/rule.py
from functools import reduce

def rule(val, x):
    sum = reduce(lambda x, y: x + y, x)
    if val == 1:
        if sum == 2:
            return 1
        elif sum == 3:
            return 1
        else:
            return 0
    else:
        if sum == 3:
            return 1
        return 0