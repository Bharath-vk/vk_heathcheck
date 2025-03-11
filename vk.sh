#!/bin/bash

# Function to get CPU utilization
get_cpu_utilization() {
    mpstat | awk '$3 ~ /[0-9.]+/ { print 100 - $13 }'
}

# Function to get memory utilization
get_memory_utilization() {
    free | awk '/Mem/ { print $3/$2 * 100.0 }'
}

# Function to get disk space utilization
get_disk_utilization() {
    df / | awk 'NR==2 { print $5 }' | sed 's/%//'
}

# Get utilizations
cpu_utilization=$(get_cpu_utilization)
memory_utilization=$(get_memory_utilization)
disk_utilization=$(get_disk_utilization)

# Determine health status
if (( $(echo "$cpu_utilization < 60" | bc -l) )) && \
   (( $(echo "$memory_utilization < 60" | bc -l) )) && \
   (( $(echo "$disk_utilization < 60" | bc -l) )); then
    health_status="Healthy"
else
    health_status="Not Healthy"
fi

# Output health status
if [[ $1 == "explain" ]]; then
    echo "Health Status: $health_status"
    if (( $(echo "$cpu_utilization >= 60" | bc -l) )); then
        echo "CPU utilization is too high: $cpu_utilization%"
    fi
    if (( $(echo "$memory_utilization >= 60" | bc -l) )); then
        echo "Memory utilization is too high: $memory_utilization%"
    fi
    if (( $(echo "$disk_utilization >= 60" | bc -l) )); then
        echo "Disk space utilization is too high: $disk_utilization%"
    fi
else
    echo "Health Status: $health_status"
fi
