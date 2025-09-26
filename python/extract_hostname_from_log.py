#!/bin/python3

import re
import csv

hostnames = []
with open('/var/log/syslog', 'r') as log:
    lines = log.readlines()


# Extract hostnames from log lines
for line in lines:
    hostnames.append(line.split(" ")[1])  # Assuming hostname is the 2nd element in the log line
if len(hostnames) > 1 and all(hostnames[i] == hostnames[i+1] for i in range(len(hostnames)-1)):
    myname = hostnames[0]
else:
    myname = list(set(hostnames))
print("Extracted hostnames:", myname)

# Extract dates and times from log lines and write to CSV
# Regex for date and time: e.g., 2025-09-21 14:23:45
pattern = re.compile(r'(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}:\d{2})')

with open('dates.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['date', 'time'])
    for line in lines:
        match = pattern.search(line)
        if match:
            writer.writerow([match.group(1), match.group(2)])
