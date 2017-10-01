#!/bin/sh
# Stubborn rsync - Runs a rsync stubbornly, with auto-retry and auto-kill
# By Roy Curtis, licensed under MIT, 2017

# #########
# CONFIGURATION:
# #########

# Debug this script; set to true with --debug
DEBUG=0

# How long to sleep for between retries; override with --delay x
DELAY=5s

# What port to use for rsync ssh; override with --port x
PORT=22

# How many times to retry a failed rsync; override with --retries x
RETRIES=20

# Maximum seconds rsync will wait on connection or I/O; override with --rsyncTimeout x
RSYNC_TIMEOUT=10

# Maximum time rsync can run before getting killed; override with --totalTimeout x
TOTAL_TIMEOUT=1h

# #########
# CONSTANTS:
# #########

# Standard "make sure we're in script's directory" boilerplate
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# #########
# FUNCTIONS:
# #########

function helpAndExit
{
    echo "Usage: $0 [options] source destination"
    echo
    echo "Available options (with their defaults):"
    echo "  --debug             If set, prints out all configured options"
    echo "  --delay x           Sets sleep delay between retries to x (5s)"
    echo "  --port x            Sets rsync's target SSH port to x (22)"
    echo "  --retries x         Sets amount of retries to x (10)"
    echo "  --rsyncTimeout x    Sets rsync's connection and I/O timeout to x seconds (5)"
    echo "  --totalTimeout x    Sets total rsync run time before kill to x (1h)"
    exit $1
}

# #########
# ARGUMENTS:
# #########

# https://stackoverflow.com/a/30830291
while true; do
    case "$1" in
        --help)
            echo "*** Stubborn rsync, by Roy Curtis"
            helpAndExit 0
            ;;

        --debug)
            DEBUG=1
            shift 1
            ;;

        --delay)
            DELAY="$2"
            shift 2
            ;;

        --port)
            PORT="$2"
            shift 2
            ;;

        --retries)
            RETRIES="$2"
            shift 2
            ;;

        --rsyncTimeout)
            RSYNC_TIMEOUT="$2"
            shift 2
            ;;

        --totalTimeout)
            TOTAL_TIMEOUT="$2"
            shift 2
            ;;

        -*)
            echo "!!! Unknown option: $1" >&2
            helpAndExit 1
            ;;

        *)
            if [ -z "$1" ]; then
                echo "!!! Source path is not set"
                helpAndExit 1
            fi

            if [ -z "$2" ]; then
                echo "!!! Destination path is not set"
                helpAndExit 1
            fi

            SOURCE_ARG=$1
            TARGET_ARG=$2
            break
            ;;
    esac
done

# #########
# SCRIPT:
# #########

# Debug
if [ "$DEBUG" -eq "1" ]; then
    echo "*** DEBUG ***"
    echo "SOURCE_ARG    = $SOURCE_ARG"
    echo "TARGET_ARG    = $TARGET_ARG"
    echo "DELAY         = $DELAY"
    echo "PORT          = $PORT"
    echo "RETRIES       = $RETRIES"
    echo "RSYNC_TIMEOUT = $RSYNC_TIMEOUT"
    echo "TOTAL_TIMEOUT = $TOTAL_TIMEOUT"
fi

# Begin loop

ATTEMPTS=1
while [ $ATTEMPTS -le $RETRIES ]; do
    echo "*** Attempt $ATTEMPTS out of $RETRIES..."

    # https://serverfault.com/a/460536
    timeout --foreground -s 9 $TOTAL_TIMEOUT \
        rsync -varzi --append-verify \
        --out-format='[%t] [%i] (Last Modified: %M) (bytes: %-10l) %-100n' \
        -e "ssh -p $PORT" \
        --timeout=$RSYNC_TIMEOUT \
        $SOURCE_ARG $TARGET_ARG

    if [ "$?" -eq "0" ]; then
        echo "*** rsync to $TARGET_ARG successful!"
        exit 0
    elif [ "$?" -eq "124" ]; then
        echo "!!! rsync appears to have hung, and has been killed!"
    else
        echo "!!! rsync appears to have crashed or timed out!"
    fi

    echo "*** Retrying after delay of $DELAY..."
    sleep $DELAY
    let ATTEMPTS=ATTEMPTS+1 
done