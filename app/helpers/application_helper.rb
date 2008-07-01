# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def user_to_hash(user)
    user = User.new unless user
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

  # current user's shortname helper
  def me_shortname_with_link
    user_shortname_with_link(current_user)
  end

  def user_shortname_with_link(user)
    if user
      "<a href=\"#{url_for :controller=>'users', :action=>'show', :id=>user.id}\">#{user.shortname}</a>"
    else
      "(no user)"
    end
  end


end
