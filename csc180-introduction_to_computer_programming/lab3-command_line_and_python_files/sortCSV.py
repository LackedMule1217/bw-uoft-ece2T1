import sys

FIN=""
FOUT=""
COL=""
DIR=""
nargs=len(sys.argv)
skip=False

for i in range(1,nargs):
   if not skip:
      arg=sys.argv[i]
      print("INFO: processing",arg)
      if arg == "--fin":
         if i != nargs-1:
            FIN=sys.argv[i+1]
            skip=True
      elif arg == "--fout":
         if i != nargs-1:
            FOUT=sys.argv[i+1]
            skip=True
      elif arg == "--col":
          if i != nargs - 1:
              COL = int(sys.argv[i + 1])
              skip = True
      elif arg == "--dir":
         if i != nargs-1:
            DIR=sys.argv[i+1]
            skip=True
      else:
         print("ERR: unknown arg:",arg)
   else:
      skip=False

try:
    f=open(FIN,"r")
    lines=f.readlines()
    f.close()
    accum=[]

    for line in lines:
        a=line.split("\n")[0]
        b=line.split(",")
        r=[]
        for i in b:
            r += [float(i)]
        accum += [r]

    def genSortKey(col, up):
        def key(x):
            return x[col] if up == "+" else -x[col]

        return key


    sortKey=genSortKey(COL,DIR)

    print(sorted(accum,key=sortKey))
    data = str(sorted(accum,key=sortKey))

    w=open(FOUT,"w")
    w.write(data)

except:
    print("Error!")
