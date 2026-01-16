#!/bin/bash

# ---------------- CONFIG ----------------
CONTAINER_NAME="budget_tracker_mysql"
DB_NAME="expenses_tracker"
DB_USER="root"
DB_PASSWORD="root123"

BACKUP_DIR="/root/db_backups"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_$DATE.sql"

# ---------------- LOGIC ----------------
mkdir -p $BACKUP_DIR

echo "Starting backup at $(date)"

docker exec $CONTAINER_NAME mysqldump -u$DB_USER -p$DB_PASSWORD $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    gzip $BACKUP_FILE
    echo "Backup successful: $BACKUP_FILE.gz"
else
    echo "Backup failed!"
fi

#aws s3 cp $BACKUP_FILE.gz s3://your-bucket-name/mysql/
