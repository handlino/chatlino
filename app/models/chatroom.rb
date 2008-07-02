# == Schema Information
# Schema version: 3
#
# Table name: chatrooms
#
#  id          :integer(11)     not null, primary key
#  title       :string(255)     
#  description :string(255)     
#  user_id     :integer(11)     
#  subject     :text           
#  updated_at  :datetime        
#  created_at  :datetime        
#

class Chatroom < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id

  has_many :chatroom_users
  has_many :users, :through => :chatroom_users

  def has_owner?( user )
    chatroom.owner == user
  end

end

