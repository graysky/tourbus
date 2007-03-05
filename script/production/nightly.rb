#!/bin/env ruby

today = Time.now.strftime("%Y%m%d")

# Backup blog and forum tables?
#

# Backup the DB
# try using:
# --single-transaction
#
#
`/usr/bin/mysqldump --single-transaction -u tourbus_root -pbighit tourbus_production > /home/lighty/db_backups/#{today}_backup.sql`
`/bin/gzip /home/lighty/db_backups/#{today}_backup.sql`

# Backup the images directory
`/usr/bin/zip -r /home/lighty/image_backups/#{today}_images /var/www/apps/tourbus/shared/public`

# Run the nightly tasks that might take a while
#
str = `cd /var/www/apps/tourbus/current && rake RAILS_ENV=production nightly_tasks`

puts "#{str}"
