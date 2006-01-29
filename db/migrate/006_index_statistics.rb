class IndexStatistics < ActiveRecord::Migration
  def self.up
    create_table :index_statistics, :force => true do |t|
      t.column :last_indexed_on, :datetime
    end
  end

  def self.down
    drop_table :index_statistics
  end
end
