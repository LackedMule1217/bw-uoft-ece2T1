# Embedded file name: /u/support/mathaine/conway/conwaylib.py
import random

class conway:

    def __init__(self, rows, cols, type):
        self.rows = rows
        self.cols = cols
        self.store = [ [ (random.randint(0, 1) if type == 'random' else 0) for i in range(0, cols) ] for j in range(0, rows) ]

    def getDisp(self):
        accum = ''
        for i in range(0, self.rows, 1):
            for j in range(0, self.cols, 1):
                accum += ' ' if self.store[i][j] == 0 else '*'

            accum += '\n'

        return accum

    def printDisp(self):
        print(self.getDisp())
        return True

    def setPos(self, row, col, val):
        if row >= self.rows or col >= self.cols or val != 0 and val != 1:
            return False
        self.store[row][col] = val
        return True

    def getNeighbours(self, row, col):
        accum = []
        lt = col - 1 if col > 0 else self.cols - 1
        rt = col + 1 if col < self.cols - 1 else 0
        up = row - 1 if row > 0 else self.rows - 1
        dn = row + 1 if row < self.rows - 1 else 0
        accum += [self.store[up][lt]]
        accum += [self.store[up][col]]
        accum += [self.store[up][rt]]
        accum += [self.store[row][lt]]
        accum += [self.store[row][rt]]
        accum += [self.store[dn][lt]]
        accum += [self.store[dn][col]]
        accum += [self.store[dn][rt]]
        return accum

    def evolve(self, rule):
        next = [ [ rule(self.store[r][c], self.getNeighbours(r, c)) for c in range(0, self.cols) ] for r in range(0, self.rows) ]
        self.store = [ [ next[r][c] for c in range(0, self.cols) ] for r in range(0, self.rows) ]
        return True