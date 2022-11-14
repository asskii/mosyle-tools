#!/bin/bash

# The following parameters are pulled directly from the "Parameter Values" 
section of your Backblaze deployment policy.
# Please make sure they are filled out respectively prior to your push
computername="%DeviceName%"
username="%LastConsoleUser%"
groupid="" #Specifiy Group ID
grouptoken="" #Specify Group Token
email="%Email%"
region="us-west" #Specify if account is to be deployed in specific region 
[us-west or eu-central]

# BZERROR MEANINGS 
# BZERROR:190 - The System Preferences process is running on the computer. 
Close System Preferences and retry the installation.
# BZERROR:1000 - This is a general error code. One possible reason is that 
the Backblaze installer doesn’t have root permissions and is failing. 
Please see the install log file for more details.
# BZERROR:1016/1003 - Login Error... Email account exists but is not a 
member of indicated Group, Group ID is incorrect, or Group token is 
incorrect,

var=0

################ FUNCTIONS #########################
function updateBackblaze {
	return=$(sudo /Volumes/Backblaze\ Installer/Backblaze\ 
Installer.app/Contents/MacOS/bzinstall_mate -upgrade bzdiy)
}

function signinBackblaze {
	return=$(sudo /Volumes/Backblaze\ Installer/Backblaze\ 
Installer.app/Contents/MacOS/bzinstall_mate -nogui 
-createaccount_or_signinaccount $email $groupid $grouptoken)
}

function createRegionAccount {
	return=$(sudo /Volumes/Backblaze\ Installer/Backblaze\ 
Installer.app/Contents/MacOS/bzinstall_mate -nogui 
-createaccount_or_signinaccount $email $groupid $grouptoken $region)
}


function successExit {
	echo "Unmounting Installer..."
	diskutil unmount /Volumes/Backblaze\ Installer
	echo "Cleaning up..."
	rm install_backblaze.dmg
	exit 0
}

function failureExit {
	echo "Unmounting Installer..."
	diskutil unmount /Volumes/Backblaze\ Installer
	echo "Cleaning up..."
	rm install_backblaze.dmg
	exit 1
}

function killSyspref {
	killall -KILL System\ Preferences > /dev/null 2>&1
}

function setDirectory {
		cd /Users/%LastConsoleUser%
}

function downloadBackblaze {
	echo "Downloading latest backblaze client..."
	curl -s -O https://secure.backblaze.com/mac/install_backblaze.dmg 
}

function mountBackblaze {
	echo "Mounting Installer..."
	hdiutil attach -quiet -nobrowse install_backblaze.dmg 
}
###################################################

setDirectory
downloadBackblaze
mountBackblaze

#Kill System Preferences process to prevent related BZERROR
killSyspref

#Check to see if Backblaze is installed already, if so update it. Else 
continue as planned. 
if open -Ra "Backblaze" ; 
	then
  		echo "Backblaze already installed, attempting to update"
		updateBackblaze
		if [ "$return" == "BZERROR:1001" ]
			then
		   		echo "Backblaze successfully updated"
				successExit
			else
				#Try upgrade again incase there was a file 
lock on the mounted dmg causing errors
				updateBackblaze
				if [ "$return" == "BZERROR:1001" ]
					then
		   				echo "Backblaze 
successfully updated"
						successExit
					else
						echo "Backblaze was 
already installed but failed to update"
						failureExit
				fi
		fi
	else
  		echo "Confirmed Backblaze isnt installed already, 
continuing with deployment..."
fi

echo "Trying to sign in account"

if [ "$region" == "" ]
 	then
		signinBackblaze
		if [ "$return" == "BZERROR:1001" ]
			then
				echo "Backblaze successfully installed, 
$email signed in..."
				successExit
			else
				signinBackblaze
				if [ "$return" == "BZERROR:1001" ]
					then
						echo "Backblaze 
successfully installed, $email signed in..."
						successExit
					else
						echo "Failed to install 
Backblaze, errorcode: $return"
                        failureExit
				fi
		fi
	else 
		createRegionAccount
		if [ "$return" == "BZERROR:1001" ]
			then
				echo "Backblaze account successfully 
created in $region, $email signed in..."
				successExit
			else
				echo "Failed to install Backblaze, 
errorcode: $return"
				failureExit
		fi	
fi
