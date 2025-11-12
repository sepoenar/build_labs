#!/bin/bash
#set -x
#set -Eeuo pipefail

#echo ${@} #= echo ${*} ##display all passed paramiters
echo ${#} #display number of parameters
echo $0
echo $1
echo ${$} #identify the current shell process id
echo ${_} #this expands to the last argument of the last command executed

#special shell variable Internal Field Separator
#The default value of IFS is a three-character string comprising a space, tab, and newline
IFS=$'\n\t' 



Str="My File.txt"
echo $Str
echo "$Str"

ls -al # > /dev/null   #prevent display output
echo $? #display last command exit status 
