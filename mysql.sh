#!/bin/bash
# MySQL backup script by RoyCurtis

# CONFIGURATION:

# Where backups are to be kept
BACKUPDIR=/home/backups/mysql
MYSQL_CNF=/root/.my.cnf

# CONSTANTS:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
cd $DIR

# SCRIPT:
if [[ $EUID -ne 0 ]]; then
   echo -e "[ERROR] Please run this script as root/sudo."
   exit 1
fi

TIMESTAMP=`date +%H%M-%d-%m-%Y`
BACKUPPATH=${BACKUPDIR}/${1}-${TIMESTAMP}.sql.bz

echo -e "[MYSQL] Performing backup of database $1 to $BACKUPPATH"
mysqldump --defaults-file="$MYSQL_CNF" --add-drop-database --single-transaction --extended-insert \
          -u root $1 | lbzip2 -n 6 > $BACKUPPATH
