class CreateBuddyIcons < ActiveRecord::Migration
  def self.up
    create_table :buddy_icons do |t|
      t.column :type,  :string
      t.column :parent_id, :integer
      t.column :content_type, :string                                       
      t.column :filename, :string                                           
      t.column :thumbnail, :string                                          
      t.column :size, :integer                                              
      t.column :width, :integer                                             
      t.column :height, :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :buddy_icons
  end
end
