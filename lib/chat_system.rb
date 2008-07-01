module ChatSystem
  
  def self.included(base)
    base.before_filter :xhr_required, :only => ['join','leave','say','refresh_info','change_subject']
    base.before_filter :find_chatroom, :only => ['join','leave','say','refresh_info','change_subject']
  end
  
  def join
    @chatroom.users.push(current_user) if !@chatroom.users.include?(current_user)
    send_push_data("Chatroom.join(#{user_to_json(current_user)});")
  end

  def leave
    if @chatroom && chatroom.users.include?(current_user)
      chatroom.users.delete(current_user)

      send_push_data("Chatroom.leave(#{user_to_json(current_user)});")

      msg = _("You left the room. This window are not closed automatically. You are able to see previous conversation logs, but not sending new chat messages.")

      render :update do |page|
        page << "Chatroom.Event.append(#{msg.to_json})"
      end
    end
    render(:nothing => true)

  end
  
  def say
    chat_message = params['chat-input'] or return render(:nothing => true)
    
    if ! @chatroom.users.include?(current_user)
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
      :body => ApplicationController.helpers.escape_javascript( self.html_escape(msg) )
    }.to_json

    data = ""
    if ( cmd == nil || cmd == ' ' )
      data << "Chatroom.say(#{input_data}, #{user_to_json(current_user)});"
    elsif ( cmd == "me" )
      data << "Chatroom.act(#{input_data}, #{user_to_json(current_user)});"
    elsif ( cmd == "nick" )
      old_nick = current_user.nickname
      current_user.nickname = msg
      if current_user.save
        event = "#{old_nick} is now known as #{current_user.nickname}"
        data << "Chatroom.Event.append(#{event.to_json});"
        data << "Chatroom.refreshUserInfo();"
      else
        to_alert = ""
        current_user.errors.each_full { |msg| to_alert += msg + "\n" }
        data << "alert(#{to_alert.to_json});"
        current_user.nickname = old_nick
        render :update do |page|
          page<<(data)
        end
        return
      end

    elsif ( cmd == "set" )
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
        event = "#{current_user.nickname} changed #{key} to #{val}"
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

    elsif ( cmd == 'kick' )
      user = User.find(:first, :conditions => [ "nickname = ?", msg ])

      if (current_user.is_owner_of(@chatroom))
        if (user.id && @chatroom.users.include?(user) )
          @chatroom.users.delete(user)
          event_msg = (_ "#{user.shortname} is kicked by #{current_user.shortname}")
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
          if user == current_user
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
  
# def change_user_photo
#   user_photo = params['user-photo'] or return :nothing => true;
#   params['chat-input'] = "/set photo_path #{user_photo}";
#   send_chat_message
# end
# 
# def ping
#   return render(:nothing => true)
#   if !(params[:id] && current_user)
#     return render(:nothing => true)
#   end
#
#   current_user.last_seen = Time.now
#   current_user.save
#
#   chatroom = Chatroom.find(params[:id])
#
#   data = ""
#
#   if rand(chatroom.users.size) == 0
#     chatroom.users.map do |u|
#       if Time.now - u.last_seen > 600.0
#         chatroom.users.delete(u)
#         data << "Chatroom.leave(user_to_json(u));"
#       end
#     end
#   end
#
#   if data.size > 0
#     data += "Chatroom.refreshUserInfo();"
#     return send_push_data(data)
#   end
#
#   return render(:nothing => true)
# end
  
  protected
  
  def send_push_data(data)
    if(! data)
      render :nothing => true
      return
    end

    if @chatroom
      Juggernaut.send_to_channel(data, [ "chat.#{@chatroom.id}" ])
    end

    render :nothing => true
  end
  
  def find_chatroom
    @chatroom = Chatroom.find(params[:id])
  end
  
  def xhr_required
    render(:nothing => true) unless request.xhr?
  end
  
  def html_escape(s)
    s.to_s.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;").gsub(/'/,"&#145;").gsub(/\\/, "&#92;")
  end
  
end