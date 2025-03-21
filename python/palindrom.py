#!/usr/bin/python3


def checkPalindrome(str):
    if str == str[::-1]:
        check=1
    else:
        check=0
    
    return check

s = input("Enter text: ")

if bool(checkPalindrome(s)):
    print("Palindrome!")
else:
    print("NOT Palindrome!")
        