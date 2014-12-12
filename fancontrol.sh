#!/bin/bash

#display cursor again at EXIT
unhide_cursor() {
    printf '\e[?25h'
    clear
}

trap unhide_cursor EXIT;

MODEL=$(cat /proc/cpuinfo | grep Hardware | awk '{print $3}');

SYS_FAN_MODE="/sys/devices/platform/odroidu2-fan/fan_mode";
SYS_PWM_DUTY="/sys/devices/platform/odroidu2-fan/pwm_duty";
SYS_TEMP="/sys/devices/virtual/thermal/thermal_zone0/temp";

if [ "x${MODEL}" == "xODROID-XU3" ];
then
	SYS_FAN_MODE="/sys/devices/odroid_fan.14/fan_mode";
	SYS_PWM_DUTY="/sys/devices/odroid_fan.14/pwm_duty";
	SYS_TEMP="/sys/devices/virtual/thermal/thermal_zone0/temp";
fi

last=0
last_temp=0
var=100000

mean=80000

#hide cursor
printf '\e[?25l'
clear

while true; do
	#move cursor to top
	printf '\033[;H'
	sleep 1
	last_temp=$var
	var=$(< $SYS_TEMP)
	current_speed=$(< $SYS_PWM_DUTY);
	echo $var

	#echo "$var,${current_speed:22:3}" >> history

	echo $last

	mean=$(echo "$mean/10*9+$var/10" |bc -l)


	echo $mean
	echo ${mean%.*}

	var=${mean%.*}

	if [ $var -lt 60000 ] && [ $var -gt 50000 ];
	then

		if [ $last -eq 1 ] || ( [ $last -eq 2 ] && [ $var -le 54000 ] );
		then
			continue
		fi

		last=1
		echo manual > $SYS_FAN_MODE;

		echo 100 > $SYS_PWM_DUTY;
		sleep 1
		echo 40 > $SYS_PWM_DUTY;


		echo "low speed"
	else

		if [ $last -eq 2 ];
		then
			continue
		fi

		last=2

		echo auto > $SYS_FAN_MODE;
		echo "auto"
	fi
done
