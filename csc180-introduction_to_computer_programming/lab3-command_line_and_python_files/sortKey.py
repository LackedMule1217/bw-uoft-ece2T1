f=open('data2','r')
lines=f.readlines()
f.close()
accum=[]
for i in lines:
   j=i.split('\n')[0]  # first get rid of the '\n'
   k=j.split(',')      # now split on the comma
   r=[]
   for x in k:
       r += [int(x)]

   accum = accum + [r] # accumulate

def sortKey(y):
    return y[0]

print(sorted(accum,key=sortKey))
