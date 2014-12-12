#!/bin/bash

last=0
var=100000
#set auto start_temp to 50
echo 50 > /sys/devices/platform/odroidu2-fan/start_temp



while true; do
sleep 10
var=$(< /sys/devices/virtual/thermal/thermal_zone0/temp)
echo $var

echo $last

if [ $var -lt 50000 ] && [ $var -gt 40000 ];then

if [ $last -eq 1 ] || ( [ $last -eq 2 ] && [ $var -le 42000 ] );then
continue
fi

last=1
echo manual > /sys/devices/platform/odroidu2-fan/fan_mode

echo 100 > /sys/devices/platform/odroidu2-fan/pwm_duty
sleep 1
echo 34 > /sys/devices/platform/odroidu2-fan/pwm_duty


echo "low speed"
else

if [ $last -eq 2 ];then
continue
fi


last=2
echo auto > /sys/devices/platform/odroidu2-fan/fan_mode
echo "auto"

fi

done
