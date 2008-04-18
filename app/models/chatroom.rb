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
#  sketch      :text            
#  updated_at  :datetime        
#  created_at  :datetime        
#

class Chatroom < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  has_and_belongs_to_many :users

  def has_owner(user=nil)
    if !user
      return false
    end
    return (chatroom.owner == user)
  end

end

