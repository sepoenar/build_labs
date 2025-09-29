#!/bin/bash

while true; do
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
    #echo ${cpu_usage%.*}
    if (( ${cpu_usage%.*} > 80 )); then
        echo "High CPU usage detected: ${cpu_usage}%"
        # You can add additional alerting mechanisms here (e.g., send an email or notification)
    else
        echo "CPU usage is normal: ${cpu_usage}%"
    fi
    sleep 60
done
#cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
#echo $cpu_usage