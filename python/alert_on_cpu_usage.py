#!/bin/python3

import subprocess, sys

cmd = "top -bn1 | grep 'Cpu(s)' | awk '{print $2}'"
#print(subprocess.check_output(cmd, shell=True, executable="/bin/bash").decode('utf-8').strip())

while True:
    cpu_usage = subprocess.check_output(cmd, shell=True, executable="/bin/bash").decode('utf-8').strip()
    print(type(cpu_usage))
    print(cpu_usage)
    if float(cpu_usage) > 90.0:
        print("Alert! CPU usage is above 90% - current usage: {}%".format(cpu_usage))
    else:
        print("CPU usage is normal - current usage: {}%".format(cpu_usage))