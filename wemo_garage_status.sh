#!/bin/sh

startup_path=$1
hardware_id=$2
device_id=$3
status=$4
status2=$5
devname=$6

dz_index=90
dz_command="Off"

curl -s -i -H "Accept: application/json" "http://domoticz:domoticz@localhost:8080/json.htm?type=command&param=switchlight&idx=$dz_index&switchcmd=$dz_command"

#curl -s -i -H "Accept: application/json" "http://domoticz:domoticz@localhost:8080/json.htm?type=devices&idx=$dz_index"

#curl -s -i -H "Accept: application/json" "http://domoticz:domoticz@localhost:8080/json.htm?type=devices&filter=temp&used=true&order=Name"

#curl -s -i -H "Accept: application/json" "http://domoticz:domoticz@localhost:8080/json.htm?type=devices&filter=light&used=true&order=Name"

echo "switched $devname ($device_id) $dz_command"
