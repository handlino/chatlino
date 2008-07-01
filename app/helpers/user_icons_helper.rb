module UserIconsHelper
  def buddy_icon(user,size = nil )
    #check size  
    if size == :small
      grav_size = 32
    elsif size == :tiny
      grav_size = 16
    else
      grav_size = 80
    end

    # check user_buddy_type
      if user.buddy_icon  # user uploaded its icon
        src = user.buddy_icon.public_filename(size)
      else # user doesnt upload icon   
        src = gravatar_url(user.email, grav_size)
      end
  
    return image_tag(src,:class => "photo" )
  end

  def gravatar_url(email,grav_size)
      grav_url = "http://www.gravatar.com/avatar.php?gravatar_id=" + Digest::MD5.hexdigest(email.downcase) + "&amp;size=#{grav_size}"
      return grav_url
  end

  def gravator_icon(email,grav_size)
      image_tag gravatar_url(email,grav_size)
  end
end
