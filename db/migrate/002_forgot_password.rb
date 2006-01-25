class ForgotPassword < ActiveRecord::Migration
  def self.up
    # Bands and fans need new columns to support resetting passwords
    add_column :bands, :security_token, :string, :limit => 40
    add_column :bands, :token_expiry, :datetime
    add_column :fans, :security_token, :string, :limit => 40
    add_column :fans, :token_expiry, :datetime
  end

  def self.down
    remove_column :bands, :security_token
    remove_column :bands, :token_expiry
    remove_column :fans, :security_token
    remove_column :fans, :token_expiry
  end
end
