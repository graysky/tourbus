require "rails_cron"
require "acts_as_background"
ActiveRecord::Base.send :include, ActsAsBackground

unless RailsCron.table_exists?
  ActiveRecord::Schema.create_table(:rails_crons) do |t|
    t.column :command, :text
    t.column :start, :integer
    t.column :finish, :integer
    t.column :every, :integer
  end
end

unless RailsCron.content_columns.map{|a|a.name}.include? "concurrent"
  ActiveRecord::Schema.add_column :rails_crons, :concurrent, :boolean
end