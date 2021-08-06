#! /bin/bash

#This script zips and uploads usb, libvirt, and appdata.
#Please ensure that all 3 backup destinations have their own folders.

#Bucket Location (Include full upload path: e.g. b2:backkups/unraid)
bucket=""
#rclone Config Password File Path
# Create a text file with just your password in it. This is used to run rclone without interaction.
rclonepw=""
# Save locations for UNRAID backups.
# Full Paths | e.g. /mnt/user/data/unraidbackup/usb
usb=""
libvirt=""
appdata=""
zipped=""
archive=""

echo
echo "=================================="
echo "UNRAID CONFIG BACKUP - B2"
echo "THIS SCRIPT WILL ZIP, ENCRYPT AND UPLOAD ALL FILES TO B2"
echo "=================================="
echo

#Check to see if bucket variable is set - If so, run backup.
if [ -z "$bucket" ]
then

      echo "Invalid Configuration..."
      echo "Ensure all variables are set before running."
      echo

else

      #Set date.
      now=$(date +%Y-%m-%d)

      #Zip backup folders.
      echo "Running backup now..."
      echo "Zipping USB..."
      zip -r $zipped/usb.zip $usb/ > /dev/null
      echo "Done."
      echo "Zipping APPDATA..."
      zip -r $zipped/appdata.zip $appdata/ > /dev/null
      echo "Done."
      echo "Zipping LIB..."
      zip -r $zipped/libvirt.zip $libvirt/ > /dev/null
      echo "Done."
      echo

      #Copy zipped files to archive local archive folder.
      mkdir $archive/${now}
      mv $zipped/*.zip $archive/${now} 
      echo "Files moved to archive folder..."

      #Remove all files older than 30 days
      echo "Removing all backups older than 30 days..."
      find $archive/  -mtime +30 -exec rm -r {} \;
      echo "Done!"

      #Upload files to bucket.
      echo "Syncing local and remote directories..."
      echo
      rclone sync --dry-run --progress --fast-list --password-command "cat $rclonepw" $archive $bucket
      echo
      echo "Done!"
      echo



      #Remove zipped files.
      rm $zipped/usb.zip $zipped/appdata.zip $zipped/libvirt.zip
      #rm -r $usb/ $appdata/ $libvirt/
      #mkdir $usb/ $appdata/ $libvirt/

fi
