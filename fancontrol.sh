#!/bin/bash
#
# This script is part of the following repository
# https://github.com/dennisdegreef/odroid-fancontrol
#

# Check for root permissions
if [ "$(whoami)" != "root" ];
then
	echo ""
	echo "    ERROR: Please run this script as the root user";
	echo ""
	exit;
fi

# Trap function
back_to_normal() {
	echo 1 > /sys/devices/odroid_fan.14/fan_mode;
	printf '\e[?25h';
	clear;
}

# Trap certain signals
trap back_to_normal EXIT;

# Generic variables
INTERVAL=1
MODEL=$(cat /proc/cpuinfo | grep Hardware | awk '{print $3}');
LOGFILE="/var/log/temperature"

# Fan mode interpretations
FAN_MODE_AUTO=1
FAN_MODE_MANUAL=0

# Locations of the sysfs files
SYS_FAN_MODE="/sys/devices/platform/odroidu2-fan/fan_mode";
SYS_PWM_DUTY="/sys/devices/platform/odroidu2-fan/pwm_duty";
SYS_TEMP="/sys/devices/virtual/thermal/thermal_zone0/temp";

# The sysfs locations for the XU3 are different
if [ "x${MODEL}" == "xODROID-XU3" ];
then
	SYS_FAN_MODE="/sys/devices/odroid_fan.14/fan_mode";
	SYS_PWM_DUTY="/sys/devices/odroid_fan.14/pwm_duty";
	SYS_TEMP="/sys/devices/virtual/thermal/thermal_zone0/temp";
fi

# Always set to manual first
echo $FAN_MODE_MANUAL > $SYS_FAN_MODE;

# Create initial logfile if not present
if [ ! -f $LOGFILE ];
then
	touch $LOGFILE;
fi

last=0
last_temp=0
var=100000

mean=80000

# Enter infinite loop
while :; do

	# Sleep for the given interval
	sleep ${INTERVAL};

	last_temp=$var
	var=$(< $SYS_TEMP)
	current_speed=$(< $SYS_PWM_DUTY);
	echo $var

	#echo "$var,${current_speed:22:3}" >> history

	echo $last

	mean=$(echo "$mean/10*9+$var/10" |bc -l)


	echo $mean
	echo ${mean%.*}

	echo "FAN_MODE: "$(<${SYS_FAN_MODE});
	echo "================================================";

	var=${mean%.*}

	if [ $var -lt 60000 ] && [ $var -gt 50000 ];
	then

		if [ $last -eq 1 ] || ( [ $last -eq 2 ] && [ $var -le 54000 ] );
		then
			continue
		fi

		last=1
		echo $FAN_MODE_MANUAL > $SYS_FAN_MODE;

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

		echo $FAN_MODE_AUTO > $SYS_FAN_MODE;
		echo "auto"
	fi

done
