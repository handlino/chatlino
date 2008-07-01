module ChatSystem

  def self.included(base)
    base.send( :include, ChatHelper)
    base.before_filter :xhr_required, :only => ['join','leave','say','refresh_info','change_subject'] #all
    base.before_filter :find_chatroom, :only => ['join','leave','say','refresh_info','change_subject']
    base.before_filter :require_chatroom_user, :only => ['leave','say','refresh_info','change_subject']
    base.before_filter :require_chatroom_owner, :only => ['change_subject']
    base.helper :chat
  end

  def join
    @chatroom.users.push(current_user) unless @chatroom.users.include?(current_user)
    send_push_data("Chatroom.join(#{user_to_json(current_user)});")
    render :nothing => true
  end

  def leave
    @chatroom.users.delete(current_user)
    send_push_data("Chatroom.leave(#{user_to_json(current_user)});")

    msg = _("You left the room. This window are not closed automatically. You are able to see previous conversation logs, but not sending new chat messages.")

    render :update do |page|
      page << "Chatroom.Event.append(#{msg.to_json})"
    end
  end

  def disconnect
    #FIXME: 220.133.37.189 (freebsd.ihower.idv.tw)
    logger.debug( "request disconnect from #{request.remote_ip}" )
    if request.remote_ip == '127.0.0.1' || params[:secret_key] == 'blah'
      user = User.find_by_login( params[:client_id] )
      ChatroomUser.delete_all( ["user_id = ?", user.id] )
      Juggernaut.send_to_all("Chatroom.leave(#{user_to_json(user)});")
    end
    render :nothing => true
  end

  def refresh_info
    chatroom_hash = {
      :id => @chatroom.id,
      :channel => "chat.#{@chatroom.id}",
      :subject => @chatroom.subject,
      :users => @chatroom.users.map { |u| user_to_hash(u) }
    }

    render :update do |page|
      page.assign("Chatroom.info", chatroom_hash)
      page.assign("Chatroom.me", user_to_hash(current_user))
    end
  end

  def change_subject
    new_subject = params[:chatroom][:subject]
    event_msg = _("Subject is changed to #{new_subject}")
    @chatroom.update_attributes( { :subject => new_subject } )
    return send_push_data([
      "Chatroom.changeSubject(#{new_subject.to_json});",
      "Chatroom.Event.append(#{event_msg.to_json});"
    ].join(""));

    render :nothing => true
  end

  def say
    chat_message = params['chat-input'] or return render(:nothing => true)
    cmd,msg = extract_message(chat_message)
    return render :nothing => true unless ( cmd || msg )

    if cmd.blank?
      send_push_data "Chatroom.say(#{input_data(msg)}, #{user_to_json(current_user)});"
      render :nothing => true
    else
      begin
        self.send( "cmd_#{cmd}", msg)
      rescue
        render :update do |page|
          page.alert("Unknown chatroom command: #{cmd}");
        end
      end
    end
  end
  
  protected
    
  def cmd_me(msg)
    send_push_data("Chatroom.act(#{input_data(msg)}, #{user_to_json(current_user)});");
    render :nothing => true
  end

  def cmd_nick(msg)
    old_nick = current_user.name
    current_user.name = msg
    data = ""
    if current_user.save
      event = "#{old_nick} is now known as #{current_user.name}"
      data << "Chatroom.Event.append(#{event.to_json});"
      data << "Chatroom.refreshUserInfo();"
    else
      to_alert = ""
      current_user.errors.each_full { |msg| to_alert += msg + "\n" }
      data << "alert(#{to_alert.to_json});"
      current_user.name = old_nick
      render :update do |page|
        page<<(data)
      end
      return
    end
    send_push_data(data)
    render :nothing => true
  end

  def cmd_set(msg)
    data = ''
    key, val = msg.match(/^([a-z_]+) (.*)$/).captures

    old_attrs = current_user.attributes

    if !current_user.attribute_present?(key)
      to_alert = "Invalid attribute name: #{key}"
      data << "alert(#{to_alert.to_json});"
      render(:update) { |page| page<<(data) }
      return
    end

    current_user[key]=val

    if current_user.save
      event = "#{current_user.name} changed #{key} to #{val}"
      data << "Chatroom.Event.append(#{event.to_json});"
      data << "Chatroom.refreshUserInfo();"
    else
      to_alert = ""
      current_user.errors.each_full { |msg| to_alert += msg + "\n" }
      current_user.attributes= old_attrs
      render :update do |page|
        page.alert(to_alert)
      end
      return
    end
    send_push_data(data)
    render :nothing => true
  end

  def cmd_kick(msg)
    user = User.find_by_name(msg)

    if current_user.is_owner_of(@chatroom)
      if ( user && user == current_user && @chatroom.users.include?(user) )
        msg = _("You don't really mean to kick yourself, do you ?")
      elsif ( user && @chatroom.users.include?(user) )
        @chatroom.users.delete(user)
        event_msg = (_ "#{user.shortname} is kicked by #{current_user.shortname}")
        send_push_data("
        Chatroom.leave(#{user_to_json(user)});
        Chatroom.Event.append(#{event_msg.to_json});
        Chatroom.refreshUserInfo();
        ");
        render :nothing => true
        return
      else
        msg = _("User not found")
      end
    else
      msg = _("You are not allowed to kick other users")
    end

    render :update do |page|
      page << "Chatroom.Event.append(#{msg.to_json})"
    end

  end

  def cmd_exit(msg)
    leave
  end

  def cmd_refresh(msg)
    render :update do |page|
      page.call("Chatroom.refreshUserInfo")
    end
  end

  def cmd_help(msg)
    render :update do |page|
      page.call("Chatroom.showHelpDialog")
    end
  end

  def send_push_data(data)
    Juggernaut.send_to_channel(data, [ "chat.#{@chatroom.id}" ])
  end

  def find_chatroom
    @chatroom = Chatroom.find(params[:id])
  end

  def xhr_required
    render(:nothing => true) unless request.xhr?
  end

  def require_chatroom_user
    @chatroom = Chatroom.find(params[:id])
    unless @chatroom.users.include?(current_user)
      render :update do |page|
        msg = _("Your are not allowed to send chat message to this room")
        page << "Chatroom.Event.append(#{msg.to_json})"
      end
      return false
    end
  end

  def require_chatroom_owner
    @chatroom = Chatroom.find(params[:id])
    unless current_user.is_owner_of(@chatroom)
      render :update do |page|
        msg = _("Your are not allowed to do this operation in this room")
        page << "Chatroom.Event.append(#{msg.to_json})"
      end
      return false
    end
  end

  def extract_message(chat_message)
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

    return cmd,msg
  end

  def input_data(msg)
    t = Time.now
    return {
      :time => "#{t.hour}:#{t.min}",
      :body => ApplicationController.helpers.escape_javascript( self.html_escape(msg) )
    }.to_json
  end

  def html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;").gsub(/'/,"&#145;").gsub(/\\/, "&#92;")
  end

end
