class ChatroomsController < ApplicationController
  
  before_filter :login_required
  
  include ChatSystem

  def index
    @chatrooms = Chatroom.find(:all)
    render :layout => "application"
  end
  def new
    @chatroom = Chatroom.new

  end
  
  def create
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
end
