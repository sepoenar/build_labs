#!/usr/bin/python3

import getpass
import paramiko
import time

#user interactive
dest = input("Enter dest Address: ")
user = input("Enter your username: ")
passwd = getpass.getpass()


#create ssh client
try:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())     #add hosts to known hosts file
    client.connect(
            hostname=dest,
            username=user,
            password=passwd,
            look_for_keys=False,
            allow_agent=False,
            )
    ssh_client = client.invoke_shell()
    ssh_client.send("hostname\n")
    time.sleep(5)
    output = ssh_client.recv(65000)
    print(output.decode("ascii"))

    ssh_client.close()
    client.close()
except paramiko.AuthenticationException:
    print("Wrong credentials")