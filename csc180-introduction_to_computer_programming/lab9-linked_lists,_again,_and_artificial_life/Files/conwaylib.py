import os
from time import sleep
from random import randint
from rule import rule

class conway:
    def __init__(self, num_lists, latter, type):
        self.num_lists = num_lists
        self.latter = latter
        self.type = type

        store = []
        for i in range(num_lists):
            store.append([])
        for i in range(0,num_lists,2):
            for n in range(latter):
                if type == "zeros":
                    store[i].append(0)
                elif type == "random":
                    store[i].append(randint(0,1))

        self.store = store

    def getDisp(self):
        string = ""
        for r in range(len(self.store)):
            for c in range(len(self.store[r])):
                if self.store[r][c] == 0:
                    string += " "
                elif self.store[r][c] == 1:
                    string += "*"
            string += "\n"
        return string

    def printDisp(self):
        try:
            print(self.getDisp())
            return True
        except:
            return False

    def setPos(self, row, col, val):
        try:
            assert val == 0 or val == 1
            self.store[row][col] = val
            return True

        except:
            return False

    def getNeighbours(self, row, col):
        try:
            list = []
            for r in range(row-2,row+3,2):
                while (r < 0) or (r >= len(self.store)):
                    if r < 0:
                        r += len(self.store)
                    elif r >= len(self.store):
                        r = r - len(self.store)

                for c in range(col-1,col+2):
                    while (c < 0) or (c >= len(self.store[r])):
                        if c < 0:
                            c = len(self.store[r]) + c
                        elif c >= len(self.store[r]):
                            c = c - len(self.store[r])

                    if (r%len(self.store) == row%len(self.store)) and (c%len(self.store[r]) == col%len(self.store[r])):
                        continue
                    list.append(self.store[r][c])
            return list
        except:
            return False

    def evolve(self, rule):
        temp = []
        for i in range(len(self.store)):
            temp.append([])
            for n in range(len(self.store[0])):
                temp[i].append(0)
        for i in range(0,len(self.store),2):
            for n in range(len(self.store[0])):
                temp[i][n] = rule(self.store[i][n], self.getNeighbours(i, n))
        for i in range(0,len(self.store),2):
            for n in range(len(self.store[0])):
                self.store[i][n] = temp[i][n]


H=40
V=30
C=conway(H,V,'zeros')

C.setPos(10,10,1)
C.setPos(9,10,1)
C.setPos(12,10,1)
C.setPos(10,9,1)
C.setPos(11,9,1)
C.setPos(10,11,1)
C.setPos(11,11,1)

C.setPos(10,20,1)
C.setPos(11,21,1)
C.setPos(12,19,1)
C.setPos(12,20,1)
C.setPos(12,21,1)
C.printDisp()
n=0
while True:
   C.evolve(rule)
   os.system('clear')
   C.printDisp()
   print("STEP:",n)
   sleep(0.1)
   n=n+1
