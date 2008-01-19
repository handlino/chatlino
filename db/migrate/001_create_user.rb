class CreateUser < ActiveRecord::Migration
  def self.up
    create_table :user, :options => 'engine=InnoDB default charset=utf8'  do |t|
      t.column :nickname,     :string, :limit=>45,  :null=>false
      t.column :user_name,    :string, :limit=>45,  :null=>false
      t.column :password,     :string, :limit=>45,  :null=>false
      t.column :email,        :string, :limit=>100, :default=>nil
      t.column :create_date,  :datetime, :default=>nil
      t.column :agree_term,   :string, :limit=>1,   :default=>nil
      t.column :suspend,      :string, :limit=>1,   :default=>nil
      t.column :country_id,   :string, :limit=>2,   :default=>nil
      t.column :last_login,   :datetime, :default=>nil
      t.column :photo_path,   :string, :limit=>128, :default=>"/images/buddyicon.jpg"
      t.column :openid_url,   :string
      t.column :email_confirmed, :boolean, :default => false
      t.column :last_seen, :datetime, :default => nil
    end
  end

  def self.down
    drop_table :user
  end
end

