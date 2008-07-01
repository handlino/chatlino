class ChatroomsController < ApplicationController
  
  before_filter :login_required
 
  # TODO chatroom permission

  include ChatSystem

  def index
    @chatrooms = Chatroom.find(:all)
    render :layout => "application"
  end
  def new
    @chatroom = Chatroom.new
  end
  
  def create
    @chatroom = Chatroom.new(params[:chatroom])
    @chatroom.owner = current_user
    if @chatroom.save
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
    if @chatroom.update_attributes( params[:chatroom] )
      redirect_to chatrooms_path
    else
      render :action => "edit"
    end
  end

  def destroy
    @chatroom.destroy
    redirect_to chatrooms_path
  end
  
end
