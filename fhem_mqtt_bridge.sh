#!/bin/bash

USERNAME="..."
PASSWORD="..."
HOSTNAME="hostname.fritz.box"

# Sending Log from FHEM to MQTT
echo "inform on" | \
nc 127.0.0.1 7072 | \
xargs -d$'\n' -L1 sh -c 'echo $0 | sed -e "s/\([^ ]*\)[ ]*\([^ ]*\)[ ]*\(.*\)/{\"type\": \"\1\", \"name\": \"\2\", \"value\": \"\3\"}/"' | \
while true; \
	do mosquitto_pub -h $HOSTNAME -p 8883 -t "fhem/output" --cafile ca.crt -u "$USERNAME" -P "$PASSWORD" -l -q 2; \
	sleep 1; \
done &

#receiving command from MQTT to FHEM
while true; do \
	mosquitto_sub -h $HOSTNAME -p 8883 -t "fhem/input" --cafile ca.crt -u "$USERNAME" -P "$PASSWORD"; \
	sleep 1; \
done | nc 127.0.0.1 7072 &
