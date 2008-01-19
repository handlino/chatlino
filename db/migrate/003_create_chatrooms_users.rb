# Create the join table ChatroomsUsers
class CreateChatroomsUsers < ActiveRecord::Migration
  def self.up
    create_table :chatrooms_users, :id=>false, :options => 'engine=InnoDB default charset=utf8' do  |t|
      t.column :chatroom_id, :integer
      t.column :user_id,     :integer      
    end
  end

  def self.down
    drop_table :chatrooms_users
  end
end
