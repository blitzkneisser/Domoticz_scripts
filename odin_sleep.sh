#!/bin/sh

startup_path=$1
hardware_id=$2
device_id=$3
status=$4
status2=$5
devname=$6


http GET http://192.168.0.42:8000/?action=System.Sleep

echo "done."
