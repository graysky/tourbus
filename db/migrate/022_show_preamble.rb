class ShowPreamble < ActiveRecord::Migration
  def self.up
    add_column :shows, :preamble, :string
  end

  def self.down
    remove_column :shows, :preamble
  end
end
