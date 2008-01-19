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

