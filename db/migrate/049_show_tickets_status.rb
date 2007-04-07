class ShowTicketsStatus < ActiveRecord::Migration
  def self.up
    add_column :shows, :status, :integer, :default => 0
    add_column :shows, :ticket_link, :string
  end

  def self.down
    remove_column :shows, :status
    remove_column :shows, :ticket_link
  end
end
