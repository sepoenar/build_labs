#!/bin/python3

import re
import csv

with open('/var/log/syslog', 'r') as log:
    lines = log.readlines()

# Regex for date and time: e.g., 2025-09-21 14:23:45
pattern = re.compile(r'(\d{4}-\d{2}-\d{2})[ T](\d{2}:\d{2}:\d{2})')

with open('dates.csv', 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(['date', 'time'])
    for line in lines:
        match = pattern.search(line)
        if match:
            writer.writerow([match.group(1), match.group(2)])