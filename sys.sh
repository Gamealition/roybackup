#!/bin/bash
# System backup script by Roy Curtis

# CONFIGURATION:

# Where backups are to be kept
BACKUPDIR=/home/backups/sys
EXCLUDE=sys.exclude

# CONSTANTS:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
cd $DIR

# SCRIPT:
if [[ $EUID -ne 0 ]]; then
   echo -e "[ERROR] Please run this script as root/sudo."
   exit 1
fi

echo -e "[SYS] Calculating backup size..."

SIZE=`du -sm --exclude-from=$EXCLUDE / 2> /dev/null | cut -f 1`
TIMESTAMP=`date +%H%M-%d-%m-%Y`
BACKUPPATH=${BACKUPDIR}/sys-${TIMESTAMP}.tar.bz

echo -e "[SYS] Performing ${SIZE}MB / (system) backup to ${BACKUPPATH}..."
tar --exclude-from=$EXCLUDE \
    -cf - / | pv -p -e -r -b -s ${SIZE}m | lbzip2 -n 6 > $BACKUPPATH
echo -e "[SYS] Finished backup to ${BACKUPPATH}"
