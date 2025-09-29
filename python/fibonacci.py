#!/bin/python3

n = int(input("Enter number: "))

def fibonacci(n):
    #print('my number:', n)
    if n <= 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fibonacci(n - 1) + fibonacci(n - 2)

print("Fibonacci sequence:")
for i in range(n):
    sequence_number = fibonacci(i)
    if sequence_number <= n:
        print(sequence_number, end="\n")
    else:
        break
    