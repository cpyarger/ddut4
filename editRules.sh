#!/bin/bash

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


if which nano &>/dev/null
	then
		editor='nano'
	else
		editor='vi'
fi

if [[ $1 == '' ]]
	then
		echo "No SRVNAME specified."
		echo "Usage: editConfig.sh SRVNAME [nosync]"
		exit 1
fi
if [[ $2 == 'nosync' ]]
	then
		nosync=1
fi

if [ ! -f ${rootdir}/ut4-"$1"/UnrealTournament/Saved/Config/LinuxServer/Rules.ini ]
	then
		echo "NOTE: ${rootdir}/ut4-$1/UnrealTournament/Saved/Config/LinuxServer/Rules.ini doesn't exist."
		read -p "Press enter to continue."
fi
$editor ${rootdir}/ut4-"$1"/UnrealTournament/Saved/Config/LinuxServer/Rules.ini

if [[ $nosync != '1' ]] && [[ $? == 0 ]]
	then
		echo "Syncing Rules.ini for ${1} to ${1}-Rules.ini"
		echo "(disable this by running editConfig.sh SRVNAME nosync)"
		cp ${rootdir}/ut4-"$1"/UnrealTournament/Saved/Config/LinuxServer/Rules.ini ${confdir}/"${1}"-Rules.ini
fi
