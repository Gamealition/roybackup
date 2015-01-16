#!/bin/bash

# Multi-target backup script by Roy Curtis

# #########
# CONFIGURATION:
# #########

# Where backups are to be kept
BACKUPDIR=/home/backups

# Home target (user data, Minecraft/Gameserv data, etc)
HOME_TARGET=/home/
HOME_NAME=home
HOME_EXCLUDE=homebackup.exclude

# System target (/etc config, /var data, etc)
SYS_TARGET=/
SYS_NAME=sys
SYS_EXCLUDE=sysbackup.exclude

# MySQL target
MYSQL_NAME=mysql
MYSQL_CNF=/root/.my.cnf

# #########
# CONSTANTS:
# #########
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
RED="\033[0;31m"
PURPLE="\033[0;35m"
BLUE="\033[0;36m"
CRESET="\033[0m"

cd $DIR

# #########
# SCRIPT:
# #########

if [[ $EUID -ne 0 ]]; then
   echo -e "[${RED}ERROR${CRESET}] Please run this script as root/sudo."
   exit 1
fi

function fileBackup
{
  echo -e "*** Calculating backup size..."

  SIZE=`du -sm --exclude-from=$EXCLUDE $TARGET 2> /dev/null | cut -f 1`
  TIMESTAMP=`date +%H%M-%d-%m-%Y`
  BACKUPPATH=${BACKUPDIR}/${NAME}-${TIMESTAMP}.tar.bz

  echo -e "*** Performing ${BLUE}${SIZE}MB${CRESET} ${TARGET} backup to ${BLUE}${BACKUPPATH}${CRESET}..."
  if [ "$1" != "--dry" ]
  then
    tar \
      --exclude-from=$EXCLUDE \
      -cf - $TARGET | pv -p -e -r -b -s ${SIZE}m | bzip2 -c > $BACKUPPATH
  fi
  echo -e "*** Finished backup to ${BLUE}${BACKUPPATH}${CRESET}"
}

function sqlBackup
{
  TIMESTAMP=`date +%H%M-%d-%m-%Y`
  BACKUPPATH=${BACKUPDIR}/${NAME}-${TIMESTAMP}.tar.bz

  echo -e "*** Performing MySQL backup to ${BLUE}${BACKUPPATH}${CRESET}..."
  mysqldump --defaults-file="$MYSQL_CNF" -u root --all-databases | gzip > $BACKUPPATH
  echo -e "*** Finished backup to ${BLUE}${BACKUPPATH}${CRESET}"
}

case "${@: -1}" in
	home)
    TARGET=$HOME_TARGET
    NAME=$HOME_NAME
    EXCLUDE=$HOME_EXCLUDE
    fileBackup
    ;;
	sys)
    TARGET=$SYS_TARGET
    NAME=$SYS_NAME
    EXCLUDE=$SYS_EXCLUDE
    fileBackup
    ;;
  mysql)
    NAME=$MYSQL_NAME
    TARGET=$MYSQL_CNF
    sqlBackup
    ;;
	*)
    echo -e "[${BLUE}USAGE${CRESET}] roybackup ([--dry] home|sys)|mysql"
    exit 1
esac