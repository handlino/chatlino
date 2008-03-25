# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def user_to_hash(user)
    user = User.new unless user
    {
      :id => user.id,
      :user_name => user.user_name,
      :shortname => user.shortname,
      :photo_path => user.photo_path,
      :link_to_shortname => "<a href=\"#{url_for :controller=>'user', :action=>'show', :id=>user.id}\">#{user.shortname}</a>"
    }
  end

  def user_to_json(user)
    user_to_hash(user).to_json
  end

  # current user's shortname helper
  def me_shortname_with_link
    user_shortname_with_link(@me)
  end

  def user_shortname_with_link(user)
    if user
      "<a href=\"#{url_for :controller=>'user', :action=>'show', :id=>user.id}\">#{user.shortname}</a>"
    else
      "(no user)"
    end
  end


end