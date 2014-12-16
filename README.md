This is a simple backup script for a few servers I have administered. Originally two files, it is now combined into one that uses "targets" to decide what to backup. Some target uses an exclusion file.

# Installation

1. `apt-get install tar pv bzip2 coreutils` or distrobution equivalent
2. Clone this repository into any directory
3. Check the `*.exclude` files and ensure the patterns are not excluding anything you want
4. `chmod +x roybackup`

# Usage

```shell
# For system backups
roybackup sys

# For home directory/user data backups
roybackup home

# For MySQL data backups
roybackup mysql

# To check the size and destination of the backup without doing any actual backing up
roybackup --dry sys
roybackup --dry home
```

## crontab
```shell
# Every three days at 3 AM
0  3 */3 * * /home/user/roybackup sys
# Every three days at 3:15 AM
15 3 */3 * * /home/user/roybackup home
# Every day at 3:30 AM
30 3 * * * /home/user/roybackup mysql
```

# Targets

## `sys`

The `sys` target is for system files from the `/` root. This includes `/etc /var /usr` (etc.) but **excludes** transient directories such as `/tmp /media /sys` (etc.) and also **excludes** directories used by the `home` target such as `/home /srv`.

## `home`
The `home` target is for user files which may be gigabytes to terabytes larger than the system backup. This is set to the `/home` directory by default and **excludes** all kinds of transient files, including but not limited to:

* Minecraft Dynmap tiles
* Source engine maps and packages

***Note that some servers, by convention, store this kind of data under different directories (e.g. /srv).***

## `mysql`
This uses `mysqldump` to take and gzip a dump of all MySQL databases on the system's installation. This target requires the use of a `.cnf` file that has the password for the MySQL user `root`, in order to perform the dumps. See http://dev.mysql.com/doc/refman/5.1/en/password-security-user.html for more information.

# Exclusions

Both targets have common exclusions for transient files that should not be included in a backup, including but not limited to:

* Backup, cache, log and tmp directories (and variants thereof)
* `*.tar.gz` files
* Log files