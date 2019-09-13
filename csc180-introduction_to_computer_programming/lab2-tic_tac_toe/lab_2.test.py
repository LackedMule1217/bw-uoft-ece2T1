import tttlib
import tttlib_ref

print "INFO: sample auto tester; goal is to achieve 0 points"

errcnt = 0
tot    = 0

print "INFO: testing genBoard"
tot    += 1
if tttlib.genBoard() != [0 for i in range(0,9) ]:
   print "ERR: -1 point"
   errcnt += 1

print "INFO: testing printBoard errors"

tot    += 2
for i in range(10,100):
   err = False
   if tttlib.printBoard([0 for i in range(0,i)]) != False:
      err = True
   if err:
      print "ERR: unchecked length"
      errcnt += 2

print "INFO: testing analyzeBoard: win cases"
for t in [ \
   [ 1,1,1, 0,0,0, 0,0,0 ], \
   [ 0,0,0, 1,1,1, 0,0,0 ], \
   [ 0,0,0, 0,0,0, 1,1,1 ], \
   [ 1,0,0, 1,0,0, 1,0,0 ], \
   [ 0,1,0, 0,1,0, 0,1,0 ], \
   [ 0,0,1, 0,0,1, 0,0,1 ], \
   [ 1,0,0, 0,1,0, 0,0,1 ], \
   [ 0,0,1, 0,1,0, 1,0,0 ], \
   [ 2,2,2, 0,0,0, 0,0,0 ], \
   [ 0,0,0, 2,2,2, 0,0,0 ], \
   [ 0,0,0, 0,0,0, 2,2,2 ], \
   [ 2,0,0, 2,0,0, 2,0,0 ], \
   [ 0,2,0, 0,2,0, 0,2,0 ], \
   [ 0,0,2, 0,0,2, 0,0,2 ], \
   [ 2,0,0, 0,2,0, 0,0,2 ], \
   [ 0,0,2, 0,2,0, 2,0,0 ]]:
   err = False
   dut = tttlib.analyzeBoard(t)
   ref = tttlib_ref.analyzeBoard(t)
   tot +=1
   if dut != ref:
      errcnt += 1
      err = True
      print "ERR: analyzeBoard [win]",t,dut,ref

print "INFO: testing analyzeBoard: play cases"
for i in range(0,9):
   for p in [1,2]:
      T=[0 for k in range(0,9)]
      T[i]=p
      err = False
      tot += 1
      if tttlib.analyzeBoard(T) != 0:
         err=True
         errcnt += 1
         print "ERR: analyseBoard [play]",T

print "INFO: testing analyzeBoard: draw cases"
for t in [\
   [ 1,1,2, 2,2,1, 1,1,2 ], \
   [ 2,2,1, 1,1,2, 2,2,1 ], \
   [ 1,2,1, 2,1,2, 2,1,2 ], \
   [ 2,1,2, 1,2,1, 1,2,1 ] ]:
   err = False
   tot += 1
   if tttlib.analyzeBoard(t) != 3:
      err=True
      errcnt += 1
      print "ERR: analyzeBoard [ draw]",t




print "You scored:",errcnt,"out of maximum badness",tot
