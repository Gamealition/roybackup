This is a collection of simple backup scripts for a few servers I have administered.
Some use exclusion files to filter what to backup.

There is also an "audit" script, that can be used by crontab to regularly send server
details (e.g. disk usage) to Slack.

Be warned, that these scripts are primitive. They do not stop Minecraft servers from
auto-saving prior to backup. This might result in a partial or corrupted world when
restoring from such a backup.

# Installation

1. `apt-get install tar pv lbzip2 coreutils` or distribution equivalent
1. Clone this repository into any directory
1. Check the `*.exclude` files; ensure the patterns are not excluding anything you want
1. `chmod +x *.sh` - Makes the scripts executable
1. `nano .slacktoken` - Put your Slack bot's token in here for `audit.sh`, if desired

# Usage

```shell
# For system backups
./sys.sh

# For home directory/user data backups
./home.sh username

# For MySQL data backups
./mysql.sh database

# To send an audit report to Slack
./audit.sh
```

## crontab
```shell
# Every three days at 3 AM
0  3 */3 * * /home/user/roybackup/sys.sh
# Variable times between 03:15 and 03:45
15 3 */3 * * /home/user/roybackup/home.sh vanderprot
30 3 *   * * /home/user/roybackup/home.sh ircd
45 3 *   * * /home/user/roybackup/home.sh www-data
# Variable times between 03:30 and 03:36
30 3 *   * * /home/user/roybackup/mysql.sh information_schema
32 3 *   * * /home/user/roybackup/mysql.sh performance_schema
34 3 *   * * /home/user/roybackup/mysql.sh forums
36 3 *   * * /home/user/roybackup/mysql.sh minecraft
# Send audit report to Slack every Monday at 9 AM
0  9 *   * Mon /home/user/roybackup/audit.sh
```

# Targets

## `sys.sh`

The `sys.sh` target is for system files from the `/` root. This includes `/etc /var /usr`
(etc.) but **excludes** transient directories such as `/tmp /media /sys` (etc.) and also
**excludes** the `/home` directory.

## `home`

The `home.sh` target is for user files which may be gigabytes to terabytes larger than
the system backup. This requires the username of the home directory to backup and
**excludes** all kinds of transient files, including but not limited to:

* Minecraft Dynmap tiles
* Source engine maps and packages

***Note that some servers, by convention, store this kind of data under different 
directories (e.g. /srv).***

## `mysql.sh`

This uses `mysqldump` to take and bzip2 a dump of given MySQL databases on the system's
installation. This target requires the use of a `.cnf` file that has the password for the
MySQL user `root`, in order to perform the dumps.

See http://dev.mysql.com/doc/refman/5.1/en/password-security-user.html for more info.

# Exclusions

Both targets have common exclusions for transient files that should not be included in a
backup, including but not limited to:

* Backup, cache, log and tmp directories (and variants thereof)
* `*.tar.gz` files
* Log files
