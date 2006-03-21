# Change the Links table
class AdjustLinks < ActiveRecord::Migration

  def self.up
    # Not using type column and Rails uses that for inheritance.
    remove_column :links, :type
  end

  def self.down
    add_column :links, :type, :string
  end
end
