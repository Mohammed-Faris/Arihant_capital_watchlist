#!/bin/bash

# Define the file and the line to add
file="scripts/releaseNotes.txt"
line=$1
cp $file "$file.bak"

# Write the new line to the top of the file
echo "$line" > $file
cat "$file.bak" >> $file

# Remove the backup file
rm "$file.bak"


#!/bin/bash

# Add all changes to the Git repository
git add .
echo "added"
sleep 1
git commit -m "${1}"
echo "commited"

sleep 1
git push
echo "pushed"

sleep 1
git pull
echo "pull"
