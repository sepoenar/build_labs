#!/bin/python3

'''
count = 0

while count < 101:
    if count % 5 == 0 and count % 3 == 0:
        print("FIZZBUZ--", count)
    elif count % 5 == 0:
        print("FIZZ--", count)
    elif count % 3 == 0:
        print("BUZZ--", count)
    else:
        print("---",count)
    
    count = count + 1
'''

for count in range(1,101):
    if count % 5 == 0 and count % 3 == 0:
        print("FIZZBUZ--", count)
    elif count % 5 == 0:
        print("FIZZ--", count)
    elif count % 3 == 0:
        print("BUZZ--", count)
    else:
        print("---",count)

