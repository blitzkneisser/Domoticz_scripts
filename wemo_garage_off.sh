#!/bin/sh

startup_path=$1
hardware_id=$2
device_id=$3
status=$4
status2=$5
devname=$6

#echo "startup_path=${startup_path}, hardware_id=${hardware_id}, device_id=${device_id}, status=${status}, status2=${status2}, devname=${devname}"

wemo switch "Heizung Garage" off

echo "switched off"
