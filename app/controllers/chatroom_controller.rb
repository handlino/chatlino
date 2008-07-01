class ChatroomController < ApplicationController

  before_filter :login_required

  def index
    @chatrooms = Chatroom.find(:all)
    render :layout => "application"
  end

  def show
    @subject_prefix = "chat"
    @chatroom = Chatroom.find(params['id'])
  end

  def create
   if request.post?
      @chatroom = Chatroom.new(params[:chatroom])
      @chatroom.owner = current_user
      @chatroom.save
      flash.now[:notice] = _("New Chatroom Is Created.")
      return index()
    end
    render :action => 'edit', :layout => "application"
  end

  def edit
    if request.post?
      Chatroom.update(params[:chatroom][:id], params[:chatroom])
      flash.now[:notice] = _("New Chatroom Is Saved.")
    end

    if ( params[:id] )
      @chatroom = Chatroom.find(params[:id] )
    else
      @chatroom = Chatroom.new
    end

    render :action => 'edit', :layout => "application"
  end

  # destroy
  def close
    c = Chatroom.find(params[:id])
    if c.owner == current_user
      Chatroom.delete(params[:id])
      flash.now[:notice] = _("The chatroom is deleted.")
    end

    if request.xhr?
      params[:id] = params[:list_id]
      return show_list
    end
  end

end


