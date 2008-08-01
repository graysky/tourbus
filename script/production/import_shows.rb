#!/bin/env ruby
#
# Import shows using anansi

# Does full import
anansi = `cd /var/www/apps/tourbus/current && rake anansi_complete &`
puts "#{anansi}"
