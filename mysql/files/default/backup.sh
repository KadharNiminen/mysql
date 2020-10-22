#!/bin/bash
for DB in $(mysql -e 'show databases' -s --skip-column-names); do
    mysqldump $DB > "/tmp/backup/$DB.sql";
done

gsutil cp /opt/backup gs://backup-bucket/mysql-"${date}"
