This is a collection of simple backup scripts for a few servers I have administered. Some use exclusion files to filter what to backup.

# Installation

1. `apt-get install tar pv bzip2 coreutils` or distribution equivalent
2. Clone this repository into any directory
3. Check the `*.exclude` files and ensure the patterns are not excluding anything you want
4. `chmod +x *.sh`

# Usage

```shell
# For system backups
sys.sh

# For home directory/user data backups
home.sh username

# For MySQL data backups
mysql.sh database
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
```

# Targets

## `sys.sh`

The `sys.sh` target is for system files from the `/` root. This includes `/etc /var /usr` (etc.) but **excludes** transient directories such as `/tmp /media /sys` (etc.) and also **excludes** the `/home` directory.

## `home`

The `home.sh` target is for user files which may be gigabytes to terabytes larger than the system backup. This requires the username of the home directory to backup and **excludes** all kinds of transient files, including but not limited to:

* Minecraft Dynmap tiles
* Source engine maps and packages

***Note that some servers, by convention, store this kind of data under different directories (e.g. /srv).***

## `mysql.sh`
This uses `mysqldump` to take and bzip2 a dump of given MySQL databases on the system's installation. This target requires the use of a `.cnf` file that has the password for the MySQL user `root`, in order to perform the dumps. See http://dev.mysql.com/doc/refman/5.1/en/password-security-user.html for more information.

# Exclusions

Both targets have common exclusions for transient files that should not be included in a backup, including but not limited to:

* Backup, cache, log and tmp directories (and variants thereof)
* `*.tar.gz` files
* Log files