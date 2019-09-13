
# coding: utf-8

# In[3]:


# <shijie wei> <1003846760>

"""* Write a function Palindromize(word) that returns a palindrome
   generated from the input word as you can infer from the example below:
      Palindromize("abc") -> "abcba"
   Hint 1: range(a,b,c) generates a list from "a" to "b" in steps of "c" NOT including "b"
   Hint 2: c can be negative, if you want to go downwards
   Hint 3: the length of a word is "len(word)"
           the first char is word[0]
   Hint 4: you can concatenate a string from its letters via "+"
   Hint 5: if I wanted to re-construct a string by concatenation of its letters:
           accumulator = ''
           for i in range(0,len(word),1):
              accumulator = accumulator + word[i]"""

def Palindromize():
    #below is the datapath
    word=str(raw_input("Enter a string to be palindromized: "))

    #below is the control
    word+=(word[len(word)-2::-1])

    print(word)

Palindromize()


# In[11]:


"""* Write a function "babylonSqrt(x,accuracy)" that takes in
   "x" (whose square root we want to determine), and "accuracy" (the desired
   accuracy of the answer), and returns the square root of "x" calculated
   via the Babylonian method of square roots"""

#Datapath
import math

while True:
	try:
		number = float(raw_input("Enter a number to be square rooted: "))
		accuracy = float(raw_input("Enter the desired accuracy of the answer (such as 0.001): "))
		assert number/abs(number)==1
		assert accuracy < 1
		break
	except:
		print("ERR")

#Control
def babylonSqrt(x, accuracy):
    guess = x/2
    while True:
        check=x/guess
        guess=0.5*(guess+check)

        if abs(guess**2-x) < accuracy:
            print(round(guess, int(abs(round((math.log(accuracy, 10)),0)))))
            break
        else:
            continue

babylonSqrt(number, accuracy)


# In[36]:


"""* Write a function "LeibnizPi(n)" that computes Pi according to the
  Leibniz formula, using "n" terms of the right-hand side series as per
  the definition below:
    pi/4 - 1 = - 1/3 + 1/5 - 1/7 + 1/9 - ... 1/(2*n+1)"""

#Datapath
while True:
   try:
       number = int(raw_input("Enter the number of terms to calculate pi: "))
       assert number / abs(number) == 1
       break
   except:
       print("ERR")

#Control
def LeibnizPi(n):
	result = 0
	for a in range(1, n+1, 2):
		result += -(1/float(2*a+1))
	for b in range(2, n+1, 2):
		result += (1/float(2*b+1))
	result = (result+1)*4
	print(result)

LeibnizPi(number)

