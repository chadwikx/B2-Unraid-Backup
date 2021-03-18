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
      zip -r usb.zip $usb/ > /dev/null
      echo "Done."
      echo "Zipping APPDATA..."
      zip -r appdata.zip $appdata/ > /dev/null
      echo "Done."
      echo "Zipping LIB..."
      zip -r libvirt.zip $libvirt/ > /dev/null
      echo "Done."
      echo

      #Upload files to bucket.
      echo "Uploading zipped files..."
      echo
      rclone copy --progress --fast-list --password-command "cat $rclonepw" usb.zip $bucket/${now}
      echo
      rclone copy --progress --fast-list --password-command "cat $rclonepw" appdata.zip $bucket/${now}
      echo
      rclone copy --progress --fast-list --password-command "cat $rclonepw" libvirt.zip $bucket/${now}
      echo
      echo "Done!"
      echo
      #Remove zipped files.
      rm usb.zip appdata.zip libvirt.zip
      rm -r USB/ LIB/ APPDATA/
      mkdir USB/ APPDATA/ LIB/
fi