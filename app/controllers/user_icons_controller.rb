class UserIconsController < ApplicationController
  def show
    @buddy_icon = BuddyIcon.new
  end

  def create

    @old_buddy_icon_id =  current_user.buddy_icon.id if current_user.buddy_icon
    @buddy_icon = BuddyIcon.new(params[:buddy_icon])
    @buddy_icon.user_id = current_user.id
      
    if @buddy_icon.save
      UserBuddyIcon.destroy_all(["id =?",@old_buddy_icon_id ]) if @old_buddy_icon_id
      # notice_stickie "Buddy icon updated"
      redirect_to edit_user_path(current_user)
    else
      #warning_stickie ("Upload failed, do you want to retry?")
      render :action => "show"
    end

  end

  def destroy
    if current_user.buddy_icon
      current_user.buddy_icon.destroy
    end

    redirect_to edit_user_path(current_user)
  end

end
