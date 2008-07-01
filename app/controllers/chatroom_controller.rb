class ChatroomController < ApplicationController

  before_filter :require_login
  before_filter :check_push_solution

  def index
    @chatrooms = Chatroom.find(:all)
    render :layout => "application"
  end

  def all
    @chatrooms = Chatroom.find(:all)
    render :action => "all", :layout => "application"
  end

  def show
    @subject_prefix = "chat"
    @chatroom = Chatroom.find(params['id'])
  end

  def create
    if request.xhr?
      @chatroom = Chatroom.new

      if params[:chatroom]
        if params[:agree_toc]
          @chatroom = Chatroom.new(params[:chatroom])
          @chatroom.owner = @me
          @chatroom.save
          flash.now[:notice] = _("New Chatroom Is Created.")
          params[:id] = params[:return_to_list] || "my"
          params[:subject] = @chatroom.subject
          return show_list
        else
          flash.now[:error] = _("Without agreeing the Terms of Conditions, you cannot create your Chatroom.")
          @chatroom = Chatroom.new(params[:chatroom])
        end
      end

      @chatroom.subject = params[:subject] if params[:subject]
      @chatroom.title = params[:title] if params[:title]

      render :update do |page|
        page.replace_html("chatroom-list", :partial => "creation_form",
                          :locals => {
                            :chatroom => @chatroom,
                            :return_to_list => params[:return_to_list],
                            :subject => params[:subject]
                          })
      end
      return
    end

    if request.post?
      @chatroom = Chatroom.new(params[:chatroom])
      @chatroom.owner = @me
      @chatroom.save
      flash.now[:notice] = _("New Chatroom Is Created.")
      return all()
    end
    render :action => 'edit', :layout => "application"
  end

  def show_list
    if params[:id]
      @chatroom_warning = StaticPage.content_by_subject_and_locale("chatroom_warning", @app_locale, _("Chatroom warning"))
      message_if_empty = _("Empty List")
      case params[:id]
      when "all" then
        list = Chatroom.find(:all, :page => { :size => 8, :current => (params[:page] || 1) })
      when "hottest" then
        @root_room = Chatroom.find(:first)
        list = Chatroom.hottest(8)
        message_if_empty = render_to_string :partial => "/chatroom/hottest_chatroom_description"
      when "recently_created" then
        list = Chatroom.latest(8)
      when "my" then
        list = @me.chatrooms
      when "my_favorites" then
        list = @me.favorite_chatrooms
      when "with_subject" then
        title = _("Chatrooms talking about this target")
        list = Chatroom.find(:all, :conditions => [ "subject = ?", params[:subject] ])
      when "most_popular" then
        list = FavoriteChatroom.find(:all,
                                     :select => "item_id, count(user_id) as user_count",
                                     :group => "item_id", :order => "user_count DESC",
                                     :page => { :size => 8, :current => (params[:page] || 1) }
                                     )
      else
        list = Chatroom.hottest(8)
      end

      render :update do |page|
        page.replace_html("chatroom-list",
                          :partial => "quick_list",
                          :locals => {
                            :list_id => params[:id],
                            :list_title => defined?(title) ? title : ( params[:id] + "_chatrooms" ),
                            :chatroom_list => list,
                            :message_if_empty => message_if_empty
                          })
        if flash.now[:notice]
          page.call("message", _("Notice"), flash.now[:notice] )
          page.replace_html("chatroom-menu",
                            :partial => "/chatroom/chatroom_menu")
        end
        page<<("Localization.show_dates_as_local_time()")
      end
    end
  end

  def search
    if params[:q].length > 0
      list = Chatroom.find_by_contents(params[:q])
      render :update do |page|
        page.replace_html("chatroom-list",
                          :partial => "quick_list",
                          :locals => {
                            :list_title =>
                            sprintf(_("Search result for %s"), params[:q]),
                            :chatroom_list => list
                          })
        page.visual_effect("highlight", "chatroom-list")
      end
      return
    end
    render :update do |page|
      page.call("Ext.Msg.alert", _("Empty Search String"), _("Enter something if you really want to search. eg. 2303, GOOG, shlee, ..."))
    end
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

  def close
    c = Chatroom.find(params[:id])
    if c.owner == @me
      Chatroom.delete(params[:id])
      flash.now[:notice] = _("The chatroom is deleted.")
    end

    if request.xhr?
      params[:id] = params[:list_id]
      return show_list
    end
  end

  def leave
    if params[:id]
      chatroom = Chatroom.find(params[:id])
    else
      return render(:nothing => true)
    end

    if chatroom && chatroom.users.include?(@me)
      chatroom.users.delete(@me)

      send_push_data("Chatroom.leave(#{user_to_json(@me)});")

      msg = (_ "You left the room. This window are not closed automatically. You are able to see previous conversation logs, but not sending new chat messages.")
      render :update do |page|
        page<<("Chatroom.Event.append(#{msg.to_json})")
      end
    end
    render(:nothing => true)
  end

  def change_my_chat_subject
    new_subject = params["chatroom-my-subject"]
    render :update do |page|
      page.call("Chatroom.changeSubject", new_subject)
    end
  end

  def restore_chat_subject
    @chatroom = Chatroom.find(params['id'])
    new_subject = @chatroom.subject || 1000
    render :update do |page|
      page.call("Chatroom.changeSubject", new_subject)
    end
  end

  def refresh_user_info
    @chatroom = Chatroom.find(params['id'])

    chatroom_hash = {
      :id => @chatroom.id,
      :channel => "chat.#{@chatroom.id}",
      :subject => @chatroom.subject,
      :users => @chatroom.users.map { |u| user_to_hash(u) }
    }

    render :update do |page|
      page.assign("Chatroom.info", chatroom_hash)
      page.assign("Chatroom.me", user_to_hash(@me))
    end
  end

  def change_user_photo
    user_photo = params['user-photo'] or return :nothing => true;
    params['chat-input'] = "/set photo_path #{user_photo}";
    send_chat_message
  end

  def save_chatlog
    if request.post?
      render :update do |page|
        page.alert(_("Not Implemented"))
      end
      return
    end
    render :nothing => true
  end

  def send_join
    @chatroom = Chatroom.find(params[:id])
    @chatroom.users.push(@me) if !@chatroom.users.include?(@me)
    send_push_data("Chatroom.join(#{user_to_json(@me)});")
  end

  def send_leave
    @chatroom = Chatroom.find(params[:id])
    @chatroom.users.delete(@me)
    render :nothing => true
  end

  def send_chat_message
    chat_message = params['chat-input'] or return render(:nothing => true)
    @chatroom = Chatroom.find(params[:id])
    if ! @chatroom.users.include?(@me)
      render :update do |page|
        msg = (_ "Your are not allowed to send chat message to this room")
        page<<("Chatroom.Event.append(#{msg.to_json})")
      end
      return
    end

    if chat_message.match(/^\//)
      m = /^(?:\/( |[a-z]+))?\s?(.*)?$/um.match(chat_message)
      if m
        cmd,msg = m.captures
      else
        cmd = nil
        msg = chat_message
      end
    else
      msg = chat_message
      cmd = nil
    end

    if ( cmd == nil && msg == nil)
      return render(:nothing =>true)
    end

    t = Time.now
    input_data = {
      :time => "#{t.hour}:#{t.min}",
      :body => escape_javascript( self.html_escape(msg) )
    }.to_json

    data = ""
    if ( cmd == nil || cmd == ' ' )
      data << "Chatroom.say(#{input_data}, #{user_to_json(@me)});"
    elsif ( cmd == "me" )
      data << "Chatroom.act(#{input_data}, #{user_to_json(@me)});"
    elsif ( cmd == "nick" )
      old_nick = @me.nickname
      @me.nickname = msg
      if @me.save
        event = "#{old_nick} is now known as #{@me.nickname}"
        data << "Chatroom.Event.append(#{event.to_json});"
        data << "Chatroom.refreshUserInfo();"
      else
        to_alert = ""
        @me.errors.each_full { |msg| to_alert += msg + "\n" }
        data << "alert(#{to_alert.to_json});"
        @me.nickname = old_nick
        render :update do |page|
          page<<(data)
        end
        return
      end

    elsif ( cmd == "set" )
      key, val = msg.match(/^([a-z_]+) (.*)$/).captures

      old_attrs = @me.attributes

      if !@me.attribute_present?(key)
        to_alert = "Invalid attribute name: #{key}"
        data << "alert(#{to_alert.to_json});"
        render(:update) { |page| page<<(data) }
        return
      end

      @me[key]=val

      if @me.save
        event = "#{@me.nickname} changed #{key} to #{val}"
        data << "Chatroom.Event.append(#{event.to_json});"
        data << "Chatroom.refreshUserInfo();"
      else
        to_alert = ""
        @me.errors.each_full { |msg| to_alert += msg + "\n" }
        @me.attributes= old_attrs
        render :update do |page|
          page.alert(to_alert)
        end
        return
      end

    elsif ( cmd == 'kick' )
      user = User.find(:first, :conditions => [ "nickname = ?", msg ])

      if (@me.is_owner_of(@chatroom))
        if (user.id && @chatroom.users.include?(user) )
          @chatroom.users.delete(user)
          event_msg = (_ "#{user.shortname} is kicked by #{@me.shortname}")
          return send_data("
            Chatroom.leave(#{user_to_json(user)});
            Chatroom.Event.append(#{event_msg.to_json});
            Chatroom.refreshUserInfo();
          ");
        end
        return :nothing => true
      else
        render :update do |page|
          msg = (_ "You are not allowed to kick other users")
          if user == @me
            msg = (_ "You don't really mean to kick yourself, do you ?")
          end
          page<<"Chatroom.Event.append(#{msg.to_json})"
        end
        return
      end

    elsif ( cmd == 'exit' )
      return leave

    elsif ( cmd == 'refresh' )

      render :update do |page|
        page.call("Chatroom.refreshUserInfo")
      end
      return

    elsif ( cmd == 'help' )

      render :update do |page|
        page.call("Chatroom.showHelpDialog")
      end
      return

    else
      render :update do |page|
        page.alert("Unknown chatroom command: #{cmd}");
      end
      return
    end

    send_push_data(data);
  end

  def send_chat_subject
    if Chatroom.find(params[:id]).owner == @me then
      new_subject = params['chatroom-subject']
      event_msg = (_ "Subject is changed to #{new_subject}")
      Chatroom.update( params[:id], { :subject => new_subject } )
      return send_push_data([
                              "Chatroom.changeSubject(#{new_subject.to_json});",
                              "Chatroom.Event.append(#{event_msg.to_json});"
                            ].join(""));
    end
    render :nothing => true
  end

  def send_chart_command
    cmd = params[:cmd] or return :nothing => true
    Chatroom.update( params[:id], { :sketch => cmd });

    cmd = cmd.to_json
    event_msg = (_ "#{@me.shortname} sends new sketches.")
    send_push_data "
      Chatroom.Event.append(#{event_msg.to_json});
      Chatroom.sketch(#{cmd});
    "
  end

  def ping
    return render(:nothing => true)
    if !(params[:id] && @me)
      return render(:nothing => true)
    end

    @me.last_seen = Time.now
    @me.save

    chatroom = Chatroom.find(params[:id])

    data = ""

    if rand(chatroom.users.size) == 0
      chatroom.users.map do |u|
        if Time.now - u.last_seen > 600.0
          chatroom.users.delete(u)
          data << "Chatroom.leave(user_to_json(u));"
        end
      end
    end

    if data.size > 0
      data += "Chatroom.refreshUserInfo();"
      return send_push_data(data)
    end

    return render(:nothing => true)
  end

  def send_push_data(data)
    if(! data)
      render :nothing => true
      return
    end

    if @chatroom
      Juggernaut.send_data(data, [ "chat.#{@chatroom.id}" ])
    end

    render :nothing => true
  end

  protected

  def html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;").gsub(/'/,"&#145;").gsub(/\\/, "&#92;")
  end

end


