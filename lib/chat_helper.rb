module ChatHelper
  
  def user_to_hash(user)
    user ||= User.new
    {
      :id => user.id,
      :user_name => user.login,
      :shortname => user.shortname,
      :photo_path => ApplicationController.helpers.buddy_icon_path(user),
      :link_to_shortname => ApplicationController.helpers.link_to( user.shortname, user_path(user) )
    }
  end

  def user_to_json(user)
    user_to_hash(user).to_json
  end
  
end