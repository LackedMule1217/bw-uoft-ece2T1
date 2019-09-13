def fibonacci(u):
    if u == 0:
        return 1
    if u == 1:
        return 1
    else:
        return (fibonacci(u - 2) + fibonacci(u - 1))

for i in range(0,10):
    print(fibonacci(i))
