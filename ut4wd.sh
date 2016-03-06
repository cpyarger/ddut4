#!/bin/bash
#Snir's UT4 Server Suite
#Watchdog module

for cnffiles in ddut4_init.def
        do
                if [ -f "$cnffiles" ]
                        then
                                source "$cnffiles"
                                if [[ $? != '0' ]]
                                        then
                                                echo "Couldn't load ${cnffiles}. Terminating."
                                                exit 1
                                #no need for 'else' here
                                fi
                                #iecho "Loaded configuration file: $(pwd)/${cnffiles}"
                        else
                                echo "Couldn't find ${cnffiles}. Terminating."
                                exit 1
                fi
        done


sheader
echo "Watchdog module"
echo
if [[ $1 == '' ]]
	then
		echo "Syntax: $0 GAMETYPES (separated by space)"
		echo "Example: $0 DM CTF"
		echo
		exit 1
fi
echo "Running watchdog module in background..."
(while true
do
for i in $@
do
if [ ! -f ${rootdir}/ut4-$i/updateflag ]
	then
		cd "${rootdir}"
		./launchServer.sh $i wd &
fi
done
sleep $wdrefresh
done &) &
disown
