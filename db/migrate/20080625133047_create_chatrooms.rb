class CreateChatrooms < ActiveRecord::Migration
  def self.up
    create_table :chatrooms, :options => 'engine=InnoDB default charset=utf8' do |t|
      t.column :title, :string
      t.column :description, :string
      t.column :user_id, :integer
      t.column :subject, :text
      t.column :updated_at, :datetime
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :chatrooms
  end
end
