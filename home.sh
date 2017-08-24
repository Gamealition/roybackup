#!/bin/bash
# Home directory backup script by RoyCurtis

# CONFIGURATION:

# Where backups are to be kept
BACKUPDIR=/home/backups/home
EXCLUDE=home.exclude

# CONSTANTS:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
cd $DIR

# SCRIPT:
if [[ $EUID -ne 0 ]]; then
   echo -e "[ERROR] Please run this script as root/sudo."
   exit 1
fi

echo -e "[HOME] Calculating backup size..."

SIZE=`du -sm --exclude-from=$EXCLUDE /home/$1 2> /dev/null | cut -f 1`
TIMESTAMP=`date +%H%M-%d-%m-%Y`
BACKUPPATH=${BACKUPDIR}/$1-${TIMESTAMP}.tar.bz

echo -e "[HOME] Performing ${SIZE}MB /home/$1 backup to ${BACKUPPATH}..."
tar --exclude-from=$EXCLUDE \
    -cf - /home/$1 | pv -p -e -r -b -s ${SIZE}m | lbzip2 -n 6 > $BACKUPPATH
echo -e "[HOME] Finished backup to ${BACKUPPATH}"
