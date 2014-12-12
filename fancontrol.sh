#!/bin/bash

#displa  cursor again at EXIT
unhide_cursor() {
    printf '\e[?25h'
    clear
}
trap unhide_cursor EXIT


last=0
last_temp=0
var=100000
#set auto start_temp to 50
echo 55 > /sys/devices/platform/odroidu2-fan/start_temp
mean=80000

#hide cursor
printf '\e[?25l'
clear

while true; do

#move cursor to top
printf '\033[;H'
sleep 1
last_temp=$var
var=$(< /sys/devices/virtual/thermal/thermal_zone0/temp)
current_speed=$(< /sys/devices/platform/odroidu2-fan/pwm_duty)
echo $var

#echo "$var,${current_speed:22:3}" >> history

echo $last

mean=$(echo "$mean/10*9+$var/10" |bc -l)


echo $mean
echo ${mean%.*}

var=${mean%.*}

if [ $var -lt 60000 ] && [ $var -gt 50000 ];then

if [ $last -eq 1 ] || ( [ $last -eq 2 ] && [ $var -le 54000 ] );then
continue
fi

last=1
echo manual > /sys/devices/platform/odroidu2-fan/fan_mode

echo 100 > /sys/devices/platform/odroidu2-fan/pwm_duty
sleep 1
echo 40 > /sys/devices/platform/odroidu2-fan/pwm_duty


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
