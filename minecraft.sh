#!/bin/bash
# Minecraft directory backup script by RoyCurtis

# CONFIGURATION:

# Where backups are to be kept
BACKUPDIR=/home/backups/minecraft
EXCLUDE=${2:-minecraft.exclude}

# CONSTANTS:
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games
cd $DIR

# SCRIPT:
echo -e "[MINECRAFT] Using exclude file $EXCLUDE"
echo -e "[MINECRAFT] Calculating backup size..."

SIZE=`du -sm --exclude-from=$EXCLUDE /home/minecraft/$1 2> /dev/null | cut -f 1`
TIMESTAMP=`date +%H%M-%d-%m-%Y`
BACKUPPATH=${BACKUPDIR}/$1-${TIMESTAMP}.tar.bz

echo -e "[MINECRAFT] Performing ${SIZE}MB /home/minecraft/$1 backup to ${BACKUPPATH}..."
tar --exclude-from=$EXCLUDE \
    -cf - /home/minecraft/$1 | pv -p -e -r -b -s ${SIZE}m | lbzip2 -n 6 > $BACKUPPATH
echo -e "[MINECRAFT] Finished backup to ${BACKUPPATH}"
