This docker image can be used to backup files and MySQL databases to S3 at a certain time each day when used within `docker-compose`.

## Example

In your `docker-compose.yml` file, just add a service for the backup:

```
backup:
  image: bunchjesse/backup
  environment:
    RUNTIME: "1000" # Server time you want the backup to run
    DIRS_TO_BACKUP: /dir/to/backup # Space-separated list of directories to back up.
    TMP_STORAGE: /tmp/dir # Where we should store tmp files while creating the backup
    MYSQL_SERVICES: mysql # Space separated list of MySQL service names
    MYSQL_USER: user # MySQL username
    MYSQL_PASSWORD: password # MySQL password
    S3_BUCKET: your-bucket-us-east-1 # Name of your S3 bucket
    STACK_NAME: test-stack # Stack name (or name of the backup)
    AWS_ACCESS_KEY_ID: ENTER_YOURS # Add this if you're not using EC2 instance profiles
    AWS_SECRET_ACCESS_KEY: ENTER_YOURS # Add this if you're not using EC2 instance profiles
  volumes:
    # Add all DIRS_TO_BACKUP and TMP_STORAGE here
    - /dir/to/backup:/dir/to/backup
    - /tmp/dir:/tmp/dir
  depends_on:
    - mysql # List your MySQL services here to ensure the backup doesn't run before they're ready
```