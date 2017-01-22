#!/bin/bash

read -p "Type 'y' to overwrite all files with the latest backup: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Restoring from the latest backup..."
    duplicity \
        --no-encryption \
        --force \
        "s3://s3.amazonaws.com/$S3_BUCKET/$STACK_NAME" "/"
    echo "Done! Note: You'll need to restore MySQL databases manually from the backed-up .sql files in the $TMP_STORAGE directory."
fi
