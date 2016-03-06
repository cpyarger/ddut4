#!/bin/bash
#DDRRE's UT4 Server Suite
#Server Launcher

#Not very useful right now, FIXME: Cannot be combined with 'restart' because $2 is evaluated
if [[ $2 == 'wd' ]]
	then
		unatt=1
	else
		unatt=0
fi

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


if [[ $2 == 'restart' ]]
	then
		restart=1
	else
		restart=0
fi

if [[ $2 == 'stop' ]]
	then
		stop=1
	else
		stop=0
fi

killwait () {
	#attempt to abort gracefully then kill
	#result1=0 on success

		result1=1
		kill $1
		result1=$?
		sleep 5
		while kill -0 $1 &>/dev/null
			do
				pidclear=0
                                cnt=$(echo "$cnt + 1" | bc)
                                kill -9 $prock
				result1=$?
                                sleep 1
                                if [[ $cnt -ge 3 ]]
                                	then
                                        	break
                                fi
				#I'll assume this cannot fail in this script (this will fail if we don't own the process).
			done
}

findkill () {
	#Finds and terminates a server.
	#Syntax:
	#findkill SRVNAME
	spid=$(pgrep -f ${rootdir}/ut4-"${1}"/Engine/Binaries/Linux/${serverproc})
	if [[ $spid != '' ]]
		then
			echo "Terminating $1 instance (${spid})..."
			killwait $spid						
			if [[ $result1 == '0' ]]
				then
					spid=''
			fi
		else
			echo "No $1 instance found."
	fi
}

launchserv () {
	#Launches a server.
	#Syntax:
	#launchserv SRVNAME PARAMS

	spid=$(pgrep -f ${rootdir}/ut4-"${1}"/Engine/Binaries/Linux/${serverproc})
        if [[ $spid != '' ]]
                then
						if [[ $restart == '1' ]]
							## FIXME: this is a very ugly way to do this with all these ifs and vars
							then
								findkill "$1"
							elif [[ $stop == '1' ]]
								then
									findkill "$1"
									exit $result1
							else
									iecho "$1 is already running."
									iecho "Please add 'restart' to the script's arguments if you want to restart the server."
						fi
        fi
        if [[ $spid == '' ]]
                        then
							echo "$(date) Launching $1"
                            ${rootdir}/ut4-${1}/Engine/Binaries/Linux/${serverproc} UnrealTournament ${@:2}
        fi
}

for i in $srvnames
	do
		if [[ "$1" == $i ]]
			then
				lnccmd="$(eval echo \$${i}_CMD)"
				launchserv $1 $lnccmd
		fi
	done

#lnccmd can be our indicator that $1=$i, so:
if [[ "$lnccmd" == '' ]]
	then
		echo "Unknown server: $1"
		echo "Syntax: $0 SRVNAME [restart]"
fi
