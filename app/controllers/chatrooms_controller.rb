class ChatroomsController < ApplicationController
  
  before_filter :login_required, :except => [:disconnect]
  before_filter :require_chatroom_owner, :only => [:edit,:update,:destroy]

  include ChatSystem

  def index
    @chatrooms = Chatroom.find(:all)
  end
  
  def show
    @subject_prefix = "chat"
    @chatroom = Chatroom.find(params[:id])
    render :layout => 'chatroom'
  end
  
  def new
    @chatroom = Chatroom.new
  end
  
  def create
    @chatroom = Chatroom.new(params[:chatroom])
    @chatroom.owner = current_user
    
    if @chatroom.save
      flash[:notice] = _("New Chatroom Is Created.")
      redirect_to chatrooms_path
    else
      render :action => "new"
    end
  end
  
  def edit
    @chatroom = Chatroom.find(params[:id]) 
  end

  def update
    @chatroom = Chatroom.find(params[:id])
    if @chatroom.update_attributes(params[:chatroom]) && @chatroom.owner == current_user
      redirect_to chatrooms_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @chatroom = Chatroom.find(params[:id])
    if @chatroom.owner == current_user
      @chatroom.destroy
    end
    flash[:notice] = _("The chatroom is deleted.")
    redirect_to chatrooms_path
  end
  
  protected
  
  def cmd_muwahahaha(msg)
    new_subject = '<object width="425" height="355"><param name="movie" value="http://www.youtube.com/v/TV0gKlKYM4k&hl=en"></param><param name="wmode" value="transparent"></param><embed src="http://www.youtube.com/v/TV0gKlKYM4k&hl=en" type="application/x-shockwave-flash" wmode="transparent" width="425" height="355"></embed></object>'
    send_push_data( "Chatroom.Event.append(#{new_subject.to_json});")
    render :nothing => true
  end
  
end
