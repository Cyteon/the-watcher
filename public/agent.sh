#!/bin/bash

key=""
url=""
version=2 # for automatic updates (to be implemented)

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --key=*)      key="${1#*=}";;
        --url=*)   url="${1#*=}";;
        *)            echo "Unknown option: $1" ;;
    esac
    shift
done

echo "Sending metrics to $url"

ram_total=$(free -b | awk '/Mem:/ {print $2}')
ram_used=$(free -b | awk '/Mem:/ {print $3}')

cpu_cores=$(nproc)
cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

disk_usage=$(df / | awk 'NR==2 {print $2, $3}')
disk_capacity=$(echo "$disk_usage" | awk '{print $1 * 1024}')
disk_used=$(echo "$disk_usage" | awk '{print $2 * 1024}')

load_avg=$(cat /proc/loadavg | awk '{print $1}')

interface=$(ip route | awk '/default/ {print $5}' | head -n 1)

rx_bytes_old=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_bytes_old=$(cat /sys/class/net/$interface/statistics/tx_bytes)

# We will take avg of 2 seconds
sleep 2

rx_bytes_new=$(cat /sys/class/net/$interface/statistics/rx_bytes)
tx_bytes_new=$(cat /sys/class/net/$interface/statistics/tx_bytes)

rx_bytes=$(( (rx_bytes_new - rx_bytes_old) / 2 ))
tx_bytes=$(( (tx_bytes_new - tx_bytes_old) / 2 ))


metrics=$(jq -n \
    --arg ram_usage "$ram_used" \
    --arg ram_max "$ram_total" \
    --arg cpu_cores "$cpu_cores" \
    --arg cpu_usage "$cpu_usage" \
    --arg disk_capacity "$disk_capacity" \
    --arg disk_used "$disk_used" \
    --arg load_avg "$load_avg" \
    --arg rx_bytes "$rx_bytes" \
    --arg tx_bytes "$tx_bytes" \
    '{
        ram_usage: ($ram_usage | tonumber),
        ram_max: ($ram_max | tonumber),
        cpu_cores: ($cpu_cores | tonumber),
        cpu_usage: ($cpu_usage | tonumber),
        disk_capacity: ($disk_capacity | tonumber),
        disk_usage: ($disk_used | tonumber),
        load_avg: ($load_avg | tonumber),
        rx_bytes: ($rx_bytes | tonumber),
        tx_bytes: ($tx_bytes | tonumber),
    }')

echo "$metrics"

response=$(curl -X POST -H "Content-Type: application/json" -d "$metrics" "$url/api/agents/$key")
echo "$response"
