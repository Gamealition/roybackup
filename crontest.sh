#!/bin/sh
ROYBACKUP="/usr/local/roybackup"
# MySQL backups
${ROYBACKUP}/mysql.sh forums
${ROYBACKUP}/mysql.sh minecraft
${ROYBACKUP}/mysql.sh prism
# System
${ROYBACKUP}/sys.sh
# Minecraft
#${ROYBACKUP}/minecraft.sh Survival
#${ROYBACKUP}/minecraft.sh Direwolf20
# Home
${ROYBACKUP}/home.sh asimov
${ROYBACKUP}/home.sh gameserver
${ROYBACKUP}/home.sh posteranonymous
${ROYBACKUP}/home.sh tehrage
${ROYBACKUP}/home.sh vanderprot
${ROYBACKUP}/home.sh www-data

