#!/bin/bash
# Smack OneDrive

# OneDrive sucks, but it's all we've got. This doesn't support versioning nor capturing a restorable system state, but you'll at least have a single offsite backup of critical files
# Toss a reference to this script into a launchd "cronjob" configuration to sync as frequently as you like, and you're good to go
# This uses very little extra space on the local disk (mere megabytes for hundreds of thousands of files), but each hard link will use an inode. Unless you're backing up hundreds of millions of tiny files, this will never even come close to presenting a problem.

# Where rsync output will go
LOGFILE='/tmp/smack-onedrive.log'

# The OneDrive sync directory
DESTDIR="/Users/$USER/OneDrive/Backups"
#DESTDIR="/Users/$USER/OneDrivetestdest"

# The source directory (typically your user home)
SRCDIR="/Users/$USER/"

# A file where a list of files or patterns that should be ignored goes (including ignoring the OneDrive directory structure)
EXCLUDE="/Users/$USER/scripts/smack-onedrive-exclude.list"

#A bit of debugging info
echo "Initializing..."
echo "Logfile: ${LOGFILE}"
echo "Source directory: ${SRCDIR}"
echo "Destination directory: ${DESTDIR}"
echo "Exclusions list: ${EXCLUDE}"
echo "Starting backup..."

# Do it
rsync -avP --exclude-from=${EXCLUDE} --link-dest=${SRCDIR} ${SRCDIR}/ "${DESTDIR}"

#cp -al ${SRCDIR}#
