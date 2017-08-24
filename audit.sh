#!/bin/bash
# Audit Bot - Collects information and sends it to Slack
# By Roy Curtis, licensed under MIT, 2017
# Initial code by Robrotheram

# #########
# CONSTANTS:
# #########

# Standard "make sure we're in script's directory" boilerplate
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
# Temporary output file
OUTFILE=.audit.txt
# Gets current date and time in fancy format
DATE="$( date )"
# Gets current date and time in dd-mm-yyyy_hh-mm format
FILENAME="$( date +%d-%m-%Y_%H-%M ).txt"

# #########
# CONFIGURATION:
# #########

# Bot User OAuth token for the "Gamealition Audit Robot" app.
# Obtained from https://api.slack.com/apps/A4MKACHJT/oauth
# CONFIDENTAL - DO NOT SHARE!
TOKEN=$(cat ".slacktoken")

# Slack channel to upload the audit report to
CHANNEL="#audit"

# #########
# FUNCTIONS:
# #########

function printLn
{
    # Append both stdout and stderr to out file
    echo $1 >> $OUTFILE 2>&1
}

function printHeader
{
    printLn ""
    printLn "###########"
    printLn "# $1"
    printLn "###########"
    printLn ""
}

# #########
# SCRIPT:
# #########

# First, create audit report

touch $OUTFILE

# Audit logic

printHeader "LOCAL FREE SPACE"

printLn "### No one entry should be more than 90% used"
printLn ""
df -h >> $OUTFILE 2>&1

printHeader "LOCAL RAID INTEGRITY"

printLn "### No one entry should be marked 'degraded'"
printLn "### For storage layout, see https://docs.google.com/document/d/1u8mmbf1QpPjtMWNLR0w7sh0tEs0N_hYX3aQlPJB5j90/edit#heading=h.g20ge9p1otqx"
printLn ""
cat /proc/mdstat >> $OUTFILE 2>&1

printHeader "LOCAL BACKUP CONTENTS"

printLn "### Each directory should not have files older than 13 days"
printLn ""
ls /home/backups/*/ -lah >> $OUTFILE 2>&1

printHeader "VAULT 111 FREE SPACE"

printLn "### No one entry should be more than 95% used"
printLn ""
ssh vault@vault111 'df -h; exit' >> $OUTFILE 2>&1

# Finally, upload and delete the audit report

curl -F file=@$OUTFILE \
     -F channels="$CHANNEL" \
     -F filename="$FILENAME" \
     -F title="Audit report for $DATE" \
     -F token="${TOKEN}" \
     https://slack.com/api/files.upload >> /dev/null 2>&1

rm $OUTFILE
