#!/bin/bash
#UT4 Linux Server Updater by DDRRE
#v0.3

#Configure this script by editing ddut4.conf


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


opwd=$(pwd)
url=''
file=''
result1=''
LSDIR="${dldir}/${zipdir}"
testbins() {
#asks "which" if a binary is available, exits on false
for i in $@
	do
		if ! which $i &>/dev/null
			then
				echo "$i not found. Terminating."
				exit 2
		fi
	done
}
testbins wget unzip
askuser_ny () {
#question, default answer (0/1)
#Example: askuser_ny rly 1
#rly? (Y/N) [Y]
result1=''
def=$2
if [[ $def == '1' ]]
	then
		deft='Y'
	else
		deft='N'
		def=0
fi
while [[ $result1 == '' ]]
	do
		read -p "$1? (Y/N) [${deft}] " ansuser
		case $ansuser in
			[Yy]) result1=1
			;;
			[Nn]) result1=0
			;;
			'')result1=$def
		esac
	done
}
fetch() {
wget --unlink "$url"
}
unpack() {
if [ -d "$LSDIR" ]
	then
		rm -rf "$LSDIR"
fi
if ! echo "$file" | grep zip &> /dev/null
	then
		/bin/false
		while [[ ! $? == 0 ]]
			do
				echo "What command should I run to extract ${file}?"
				read cmnd
				eval "$cmnd" "${dldir}/${file}"
			done
	else
		echo Extracting downloaded file...
		unzip "${dldir}/${file}"
fi
}
sheader

cd "$dldir"
if [[ $1 == '' ]]
	then
		echo "Server updater v0.2"
		echo
		echo "Please provide the server package URL:"
		read url
		echo
	else
		url=$1
fi
# best regex ever, DEAL WITH IT
if [[ $url == 'install' ]]
	then
		if [ -d "${basedir}" ]
			then
				echo "Entered INSTALL mode."
				echo
				askuser_ny "Would you like to (re)deploy $basedir" 1
				if [[ $result1 == '1' ]]
					then
						#These two are actually unnecessary in this flow
						tfetch=0
						tunpack=0
						LSDIR="${basedir}"
					else
						exit 0
				fi
			else
				echo "${basedir} not found, cannot enter INSTALL mode. Terminating."
				exit 1
		fi
	else
		file=`echo $url | sed -r 's/.*\/.*\///'`
		tfetch=1
		tunpack=1
		if [ -f "${dldir}/${file}" ]
			then
				askuser_ny "$file already exists. Skip download" 1
				if [[ $result1 == '0' ]]
					then
						tfetch=1
						tunpack=1
					else
						tfetch=0
				fi
		fi
		if [ -d "$LSDIR" ] && [[ $tunpack == '1' ]] && [[ $tfetch == '0' ]]
						then
							askuser_ny "$LSDIR exists. Unzip $file anyway" 1
							tunpack=$result1
		fi
		
		if [[ $tfetch == '1' ]]
			then
				fetch
		fi
		if [[ $tunpack == '1' ]]
			then
				unpack
		fi
fi

if [ ! -d "$LSDIR" ]
	then
		while [ ! -d "$LSDIR" ] && [[ ! "$LSDIR" == '' ]] &> /dev/null
			do
				echo "Didn't find $LSDIR. Which directory has UnrealTournament in it?"
				read LSDIR
			done
fi

## FIXME: Handle LSDIR which doesn't have UnrealTournament in it (but exists, e.g. bad user input)


if [[ ! "$basedir" == "$LSDIR" ]]
	then
		rm -rf "$basedir"
		mv "$LSDIR" "$basedir" &>/dev/null
fi

if [[ $cronctl == '1' ]]
	then
		echo Stopping cron...
		sudo service cron stop
fi

for i in $update
	do
		pidclear=1
		echo "About to update ${i}."
		mkdir -p ${i} &>/dev/null
		prock=$(pgrep -f "${i}/Engine/Binaries/Linux/${serverproc}")
		if [[ ${prock} != '' ]]
			then
				echo "Sending abort signal to server instance.."
				kill $prock
				sleep 5
				while kill -0 $prock &>/dev/null
					do
						pidclear=0
						cnt=$(echo "$cnt + 1" | bc)
						echo "Sending kill signal to server instance.."
						kill -9 $prock
						sleep 1
						if [[ $cnt -ge 3 ]]
							then
								break
						fi
						pidclear=1
					done
			fi
		if [[ $pidclear == '1' ]]
			then
				echo -n "Updating ${i}..."
				touch "${i}/updateflag"
				if [ -d "${i}/UnrealTournament/Saved" ]
					then
						#Backing up the old Config folder
						cd "${i}/UnrealTournament/Saved"
						cp -r Config{,.backup.$(date +%s)}
				fi
				cd "${i}"
				if [[ $cplink == '0' ]]
					then
						cp -r "${basedir}/." ./
					else
						#using hardlink copy as default
						cp -rfal "${basedir}/." ./
				fi
				#Setting exec permissions on the server binary
				chmod ug+x "${i}/Engine/Binaries/Linux/${serverproc}"
				echo "Done."
			else
				echo "Update skipped (process still alive)"
		fi
	done
if [[ $cronctl == '1' ]]
	then
		echo Starting cron...
		sudo service cron start
fi
cd "$rootdir"

for k in $srvnames
	do
		mkdir -p "${rootdir}/ut4-${k}/UnrealTournament/Saved/Config/LinuxServer" &>/dev/null
		if [ -f ${confdir}/Engine.ini ]
			then
				echo "Copying Engine.ini to ut4-${k}"
				cp ${confdir}/Engine.ini "${rootdir}/ut4-${k}/UnrealTournament/Saved/Config/LinuxServer/"
		fi
		if [ -f ${confdir}/${k}-Game.ini ]
			then
				echo "Copying ${k}-Game.ini to ut4-${k}"
				cp "${confdir}/${k}-Game.ini" "${rootdir}/ut4-${k}/UnrealTournament/Saved/Config/LinuxServer/Game.ini"
		fi
		if [ -f ${confdir}/${k}-Rules.ini ]
			then
				echo "Copying ${k}-Rules.ini to ut4-${k}"
				cp "${confdir}/${k}-Rules.ini" "${rootdir}/ut4-${k}/UnrealTournament/Saved/Config/LinuxServer/Rules.ini"
		fi
	done

for i in $update
	do
		rm -rf "${i}/updateflag"
	done

if [ -f "${dldir}/${file}" ] && [[ $keepdl != '1' ]]
	then
		rm -rf "${dldir}/${file}"
fi
echo Update completed!
cd "$opwd"
