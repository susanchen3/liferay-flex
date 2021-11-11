#!/bin/bash

#### Constants

# set current working directory
	cwd=$(pwd)

# Exceptions
	set -e

# Check if 7z is installed
	if ! archiverLocation="$(type -p "7z")" || [[ -z $archiverLocation ]]; then
 		echo -e "\e[101m7z is not installed. Please install 7z and try again.\e[0m"
	fi
	
# Login information
# Just replace USER@liferay.com with your liferay email
	USER=USER@liferay.com
	PW=''
	
# Bundles
	SEVENTHREE='https://files.liferay.com/private/ee/portal/7.3.10/liferay-dxp-tomcat-7.3.10-ga1-20200930160533946.7z'
	SEVENTWO='https://files.liferay.com/private/ee/portal/7.2.10/liferay-dxp-tomcat-7.2.10-ga1-20190531140450482.7z'
	SEVENONE='https://files.liferay.com/private/ee/portal/7.1.10/liferay-dxp-tomcat-7.1.10-ga1-20180703090613030.zip'
	SEVENZERO='https://files.liferay.com/private/ee/portal/7.0.10/liferay-dxp-digital-enterprise-tomcat-7.0-ga1-20160617092557801.zip'
	SIXTWO='https://files.liferay.com/private/ee/portal/6.2.10/liferay-portal-tomcat-6.2-ee-ga1-20150909103437857.zip'

#### Functions

# Downloads bundles 7.3, 7.2, 7.1, 7.0, 6.2 and respective patching tools
# Also works for other portal versions, but have to manually link bundle and patching tool
bundleandpatchingtool ()
{
	local bundle
	local pt
	local portalv=$1
	
	if [[ $portalv == '7.3' ]] || [[ $portalv == '7.2' ]]
		then
			if [[ $portalv == '7.3' ]]; then bundle=$SEVENTHREE; pt='3.0.27'; fi
			if [[ $portalv == '7.2' ]]; then bundle=$SEVENTWO; pt='2.0.15'; fi
			
			echo -e "\e[44m\nDownloading the $portalv bundle\e[0m"		
			wget -c -N --user=$USER --password=$PW $bundle -P $cwd/bundles/hotfix
			7z x $cwd/bundles/hotfix/*.7z -O$cwd/bundles/hotfix
	
	elif [[ $portalv == '7.1' ]] || [[ $portalv == '7.0' ]] || [[ $portalv == '6.2' ]]
		then
			if [[ $portalv == '7.1' ]]; then bundle=$SEVENONE; pt='2.0.15'; fi
			if [[ $portalv == '7.0' ]]; then bundle=$SEVENZERO; pt='2.0.15'; fi
			if [[ $portalv == '6.2' ]]; then bundle=$SIXTWO; pt='1.0.24'; fi
			
			echo -e "\e[44mDownloading the $portalv bundle\e[0m"		
			wget -c -N --user=$USER --password=$PW $bundle -P $cwd/bundles/hotfix
			unzip $cwd/bundles/hotfix/*.zip -d $cwd/bundles/hotfix/
	else
		echo -e "\e[44mPlease only use 7z or zip for portal bundles\e[0m"
		read -p "Is the portal version a zip file? Please type Y or N: " portalver
	  	read -p 'Please specify download link for portal: ' portaldl
		wget -c -N --user=$USER --password=$PW $portaldl -P $cwd/bundles/hotfix
		if [[ $portalver == 'y' ]] || [[ $portalver == 'Y' ]]
			then
				echo -e "\e[44mDownloading the bundle\e[0m"	
				unzip $cwd/bundles/hotfix/*.zip -d $cwd/bundles/hotfix/
		else
			echo -e "\e[44mDownloading the bundle\e[0m"	
			7z x $cwd/bundles/hotfix/*.7z -O$cwd/bundles/hotfix
		fi
			
	  	read -p 'Please specify download link for patching tool: ' pt
		
	fi 
	
	echo -e "\e[44mDownloading the $pt patching tool\e[0m"
	rm -rf $cwd/bundles/hotfix/*/patching-tool
	wget -c -N --user=$USER --password=$PW https://files.liferay.com/private/ee/fix-packs/patching-tool/patching-tool-$pt.zip -P $cwd/bundles/hotfix/*/
	unzip $cwd/bundles/hotfix/*/*.zip -d $cwd/bundles/hotfix/*/	
}


# Runs auto-discovery and downloads the fixpack
dlfixpack ()
{
	local portalv=$1
	
	if [[ $portalv == '7.3' ]]; then portalv='7.3.10'; pv='7310'; pd='dxp'; fi
	if [[ $portalv == '7.2' ]]; then portalv='7.2.10'; pv='7210'; pd='dxp'; fi
	if [[ $portalv == '7.1' ]]; then portalv='7.1.10'; pv='7110'; pd='dxp'; fi
	if [[ $portalv == '7.0' ]]; then portalv='7.0.10'; pv='7010'; pd='de'; fi
	if [[ $portalv == '6.2' ]]; then portalv='6.2.10'; pv='6210'; pd='portal'; fi
	
	echo -e "\e[44mRunning auto-discovery\e[0m"
	bash $cwd/bundles/hotfix/*/patching-tool/patching-tool.sh auto-discovery 
	bash $cwd/bundles/hotfix/*/patching-tool/patching-tool.sh revert
	
	echo -e "\e[44mDownloading the fixpack\e[0m"
	read -p "Does this hotfix require a fixpack? Please type Y or N: " fixpack
	if [[ $fixpack == 'y' ]]  || [[ $fixpack == 'Y' ]]
		then
			read -p 'Fixpack number: ' fp
	wget -c -N --user=$USER --password=$PW https://files.liferay.com/private/ee/fix-packs/$portalv/$pd/liferay-fix-pack-$pd-$fp-$pv.zip -P $cwd/bundles/hotfix/*/patching-tool/patches
	fi
	
}


# Downloads the hotfix
dlhotfix ()
{
	local portalv=$1
	
	if [[ $portalv == '7.3' ]]; then portalv='7.3.10'; pv='7310'; fi
	if [[ $portalv == '7.2' ]]; then portalv='7.2.10'; pv='7210'; fi
	if [[ $portalv == '7.1' ]]; then portalv='7.1.10'; pv='7110'; fi
	if [[ $portalv == '7.0' ]]; then portalv='7.0.10'; pv='7010'; fi
	if [[ $portalv == '6.2' ]]; then portalv='6.2.10'; pv='6210'; fi
	
	echo -e "\e[44mDownloading the hotfix\e[0m"
	read -p 'Hotfix number: ' hf
	wget -c -N --user=$USER --password=$PW https://files.liferay.com/private/ee/fix-packs/$portalv/hotfix/liferay-hotfix-$hf-$pv.zip -P $cwd/bundles/hotfix/*/patching-tool/patches
	bash $cwd/bundles/hotfix/*/patching-tool/patching-tool.sh install 
}


# Deleting data, logs, and osgi/state folders
clearfd ()
{
	echo -e "\e[44mDeleting the logs, data, osgi/state folder\e[0m"
	rm -r $cwd/bundles/hotfix/*/data
	if [ -d $cwd/bundles/hotfix/*/osgi/state ]; then rm -r $cwd/bundles/hotfix/*/osgi/state; fi
	if [ -d $cwd/bundles/hotfix/*/logs ]; then rm -r $cwd/bundles/hotfix/*/logs; fi 

}


# Drops and recreates lportal
cleandb ()
{
	#read -p "Enter database name [lportal]: " db_name
	#db_name=${db_name:-lportal}
	echo -e "\e[44mDropping lportal and recreating it\e[0m"
	mysql -e "DROP DATABASE if exists lportal; create database lportal character set utf8mb4;"
}

# Replaces mysql.jar in tomcat/lib/ext
# Checks if /ext folder exists, if not then create one 
# Checks if 7.0 then use diff mysql.jar
rpmysql ()
{
	local portalv=$1

	echo -e "\e[44mReplacing the mysql.jar\e[0m"
	if [ ! -d $cwd/bundles/hotfix/*/tomcat*/lib/ext ]; then cd $cwd/bundles/hotfix/*/tomcat*/lib; mkdir ext; fi 
	cp $cwd/mysql.jar $cwd/bundles/hotfix/*/tomcat*/lib/ext

	if [[ $portalv == '7.0' ]]; then cp $cwd/7.0-mysql.jar/mysql.jar $cwd/bundles/hotfix/*/tomcat*/lib/ext; fi
}

# Places portal-ext.properties into liferay.home
portalext ()
{
	echo -e "\e[44mPlacing portal-ext into liferay.home\e[0m"
	cp $cwd/portal-ext.properties $cwd/bundles/hotfix/*/
}

# Places the activation key in deploy
# Checks if /deploy folder exists, if not then create one
placekey() 
{
	local portalv=$1

	echo -e "\e[44mPlacing the activation key into deploy\e[0m"
	if [ ! -d $cwd/bundles/hotfix/*/deploy ]; then cd $cwd/bundles/hotfix/*/; mkdir deploy; fi 
	
	if [[ $portalv == '7.3' ]]; then cp $cwd/activation-key*7.3* $cwd/bundles/hotfix/*/deploy; fi
	if [[ $portalv == '7.2' ]]; then cp $cwd/activation-key*7.2* $cwd/bundles/hotfix/*/deploy; fi
	if [[ $portalv == '7.1' ]]; then cp $cwd/activation-key*7.1* $cwd/bundles/hotfix/*/deploy; fi
	if [[ $portalv == '7.0' ]]; then cp $cwd/activation-key*7.0* $cwd/bundles/hotfix/*/deploy; fi
	if [[ $portalv == '6.2' ]]; then cp $cwd/activation-key*6.0* $cwd/bundles/hotfix/*/deploy; fi
}

dlhf()
{  
# Clean out old copy
	echo -e "\e[44mCleaning out old extracted binaries/folders\e[0m"
	rm -rf $cwd/bundles/hotfix

# Create directories that will be used
	echo -e "\e[44mCreating folders for bundle backup if they don't exist\e[0m"
	mkdir -p bundles/hotfix

# Ask which portal version
	read -p 'Specify which portal version [7.3, 7.2, 7.1, 7.0, 6.2, other]: ' portalv
	read -s -p 'Password: ' pw
	PW=$pw

# Download bundle and patching tool
	bundleandpatchingtool $portalv
  
# Navigate into patching tool and run commands to install patch
	dlfixpack $portalv
	
# Downloads hotfix 
	dlhotfix $portalv
	
# Deletes data, logs, and osgi/state folders
	clearfd

# Drops lportal and recreates it
	cleandb

# Places mysql.jar
	rpmysql $portalv

# Places portal-ext.properties	
	portalext
	
# Places activation key
	placekey $portalv
	
	echo -e "\e[44mHotfix successfully downloaded.\e[0m"
}

#### Help documentation

usage ()
{
	cat <<HELP_USAGE


	$0 <parameter>

	Parameters
	----------

	bundleandpatchingtool 		Downloads the bundle and patching tool
	dlfixpack 			Downloads the fixpack 
	dlhotfix			Downloads the hotfix
	clearfd 			Deletes data, logs, and osgi/state folders
	cleandb			Cleans the database if it already exists
	rpmysql			Replaces the mysql.jar
	portal-ext			Places the portal-ext.properties in liferay.home
	dlhf				Downloads and sets up hotfix

HELP_USAGE
}

#### Check if no parameters are sent

if [ $# -eq 0 ]
  then
    usage
fi

#### Accepts Parameters
for setupParameters in "$@"
do
    $setupParameters
done
