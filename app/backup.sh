#!/bin/bash

# Locals
timestamp="$(date +"%Y-%m-%d-%H-%M-%S")"
mysqltmpdir="$TMP_STORAGE/mysql-backup-$timestamp"

# Make temp directories
mkdir -p "$mysqltmpdir"

# Dump databases
for service in $MYSQL_SERVICES
do
    # Get all databases
    databases=`mysql -h "$service" -u $MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

    # Dump each database one-by-one
    for db in $databases; do
        if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "mysql" ]] && [[ "$db" != _* ]] ; then
            tmpfile="$db-$service-$timestamp.sql"
            tmppath="$mysqltmpdir/$tmpfile"
            mysqldump -h "$service" -u $MYSQL_USER -p$MYSQL_PASSWORD --databases $db > "$tmppath"
        fi
    done
done

# Create --include string for duplicity
includeDirs="--include=${mysqltmpdir%/}"
for dir in $DIRS_TO_BACKUP
do
    includeDirs="$includeDirs --include=${dir%/}"
done

# Cleanup
duplicity cleanup \
    --archive-dir=$TMP_STORAGE \
    --tempdir=$TMP_STORAGE \
    --no-encryption \
    --force \
    "s3://s3.amazonaws.com/$S3_BUCKET/$STACK_NAME"

# Backup
duplicity \
    --allow-source-mismatch \
    --full-if-older-than 2W \
    --volsize 1000 \
    --no-encryption \
    --archive-dir "$TMP_STORAGE" \
    --tempdir "$TMP_STORAGE" \
    --s3-use-new-style \
    --s3-use-multiprocessing \
    --s3-use-ia $includeDirs \
    -v8 \
    --exclude='**' \
    "/" "s3://s3.amazonaws.com/$S3_BUCKET/$STACK_NAME"

# Notify CloudWatch if backup succeeded
if [ $? -eq 0 ]; then
    aws cloudwatch put-metric-data \
        --metric-name BackupSuccess \
        --namespace Backup \
        --dimensions "Stack=$STACK_NAME" \
        --value 1 \
        --unit Count \
        --region us-east-1
fi

# Cleanup
rm -rf "$mysqltmpdir"

echo "Backup finished."
