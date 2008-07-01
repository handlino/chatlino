Chatroom = function() { };

Chatroom.prototype = {
    me: null,
    info: null,
    name: "",
    target: -1,
    layout: {},
    config: { ipush: { } },

    init: function(chatroom, me) {
        this.info = chatroom;
        this.me   = me;
        this.me.is_owner = (chatroom.owner.id == me.id);
        this.status = {
            connected: false,
            'synchronize_subject': true
        };
    },

    connect: function() {
        
    },

    say: function(message, me) {
        if (typeof(me) == 'undefined')
            me = this.me

        try {
            new Insertion.Bottom('chat-data-tbody',
                this.make_chat_message("message",
                message, me));
            this.scrollToBottom();
        } catch(e) {
        }
    },
    act: function(message, me) {
        if (typeof(me) == 'undefined')
            me = this.me

        try {
            new Insertion.Bottom('chat-data-tbody',
                this.make_chat_message("act", message,
                me));
            this.scrollToBottom();
            new Effect.Highlight($("chat-data-tbody").lastChild,
                                 {startcolor:'#ff9999', endcolor:'#ffffaa'})
        } catch(e) {
        }
    },
    nick: function(message, me) {
    },
    make_chat_message: function(message_class, message, me) {
        var user_class = 'user-id-' + me.id;
        message_class = "chat-data-" + message_class;
        var html = '<tr class="' + message_class + ' ' + user_class +'">'
                + '<td class="chat-data-time">'
                + message.time
                + '</td>'
                + '<td class="chat-data-username">'
                + '<img width="24" height="24" src="' + me.photo_path + '">'

                + ( ( message_class == "chat-data-message") ?
                    ('<span class="username">' + me.shortname + '</span>') :'')

                + '</td><td class="chat-data-sentence">'

                + ( (message_class == "chat-data-act") ?
                    ('<span class="username">' + me.shortname + '</span> ') :'')

                + '<span>'
                + Chatroom.filter_message(message.body)
                + '</span></td></tr>';

        return html;
    },

    join: function(me) {
        var user_element_id = "chatroom-userlist-user" + me.id
        Chatroom.Event.append(me.shortname + " joined")
        if ( !$(user_element_id) ) {
            new Insertion.Bottom("chatroom-userlist",
                    '<div class="item" id="'
                    + user_element_id + '">'
                    + '<img alt="Buddyicon" height="24" width="24" src="'
                    + me.photo_path + '">'
                    + '<span>'
                    + me.link_to_shortname
                    + '</span>'
                    + '</div>')
            new Effect.Highlight(user_element_id)
        } else {
            new Effect.Appear("chatroom-userlist-user" + me.id, {duration: 3.0})
            new Effect.Highlight(user_element_id)
        }
    },
    leave: function(me) {
        Chatroom.Event.append(me.shortname + " just left this channel");
        var elem = $("chatroom-userlist-user" + me.id)
        if (elem)  { new Effect.SwitchOff(elem) }
    },
    changeSubject: function(new_subject) {
        this.subject = new_subject;
        $("chat-subject-object").innerHTML = new_subject;
    },
    toggleSync: function(item, pressed) {
        if (pressed) {
            Chatroom.combo.container.hide();
        } else {
            Chatroom.combo.container.show();
        }
    },
    focusOnInput: function() {
        Chatroom.setKeyBinding();
        var f = function() {
            try {
                $("chat-input").focus();
                Chatroom.connect();
            } catch(e) {
                setTimeout(f, 500);
            }
        }
        f();
    },
    setKeyBinding: function() {
        Event.observe($("chat-input"), "keypress", function(e) {
            var k = e.keyCode;
            if (k == 13) {
                if ( $("chat-input").value.match(/\S/) ) {
                    $("chat-input").value =
                    $("chat-input").value.replace(/\s+$/,"");
                    $("chat-input-submit").click();
                    Form.disable("chat-input-form");
                }
                Event.stop(e);
            }
            else if ( k == 9 || k == 27) {
                Event.stop(e);
            }
        })
    },
    filter_message: function(message) {
        message = message.replace(/\\n/g,"\n")
        if (message.match(/\n/)) {
            message = "<pre>" + message + "</pre>"
        }
        var filter_function = function(str) {
            if ( str.match(/(png|jpg|gif)/) ) {
                var img_html = '<img style="display:relative;width:100%;" src="' + str + '" onclick="Chatroom.showImageLightbox(this); return false;" />';
                return '<div style="width:64px;">' + img_html + '</div>'
            }
            else {
                return "<a target=\"_blank\" href=\"%s\">%s</a>".replace(/%s/g, str)
            }
        }
        message = message.replace(/http:\S+/ig, filter_function);
        message = Asynapse.Emoticon.MSN.filter_text(message)
        return message
    },
    showImageLightbox: function(e) {
        var fit = this.fitImage(e.src, 500);
        var img_html = '<img style="width:100%;" src="' + e.src + '" />';
        var box = new Widget.Lightbox();
        box.config.width  = fit.width + "px"
        box.content(img_html);
        box.show();
    },
    subjectDialog: {},
    showSubjectDialog: function(p_sType, p_aArguments) {
        subjectDialog.show();
    },
    onMenuReady: function() {

        chatMenu.render();
    },
    refreshUserInfo: function() {
        new Ajax.Request('/chatroom/' + this.info.id + '/refresh_info', {
            onComplete: function() {
                Chatroom.redrawUserList()
                Chatroom.redrawMyIcon()
            }
        })
    },
    redrawMyIcon: function() {
        var fit = this.fitImage( this.me.photo_path, 55);

        with($("chat-input-userinfo-photo")) {
            setAttribute("src",   this.me.photo_path)
            setAttribute("width", fit.width)
            setAttribute("height", fit.height)
            setAttribute("style", "border:none;")
        }

        document.getElementsByClassName("user-photo").each(function(e) {
            e.setAttribute("src", this.me.photo_path)
        });
    },
    redrawUserList: function() {
        $("chatroom-userlist").innerHTML = ""

        this.info.users.each( function(u) {
            var t = '<div class="item" id="chatroom-userlist-%USER_ID"><img alt="%USER_NAME" src="%USER_PHOTO" height="24" width="24"><span>%USER_LINK_TO_SHORTNAME</span></div>'
            .replace(/%USER_ID/g, u.id)
            .replace(/%USER_NAME/g, u.shortname)
            .replace(/%USER_PHOTO/g, u.photo_path)
            .replace(/%USER_LINK_TO_SHORTNAME/g, u.link_to_shortname)

            new Insertion.Bottom("chatroom-userlist",t)
        })

    },

    initChangeUserPhotoHandler: function() {
        
    },

    lightbox: null,
    changeUserPhoto: function() {
        var html = $("change-user-photo-dlg-content").innerHTML;
        alert("no dialog variable.");
    },

    scrollToBottom: function() {
        var e = $("chat-data").parentNode;
        e.scrollTop = e.scrollHeight;
    },

    showDialog: function() {
        alert("no dialog variable.");
    },
    showHelpDialog: function(tab) {
        alert("no dialog variable.");
    },
    fitImage: function(url, bound) {
        var i = new Image()
        i.src = url

        var ratio = bound / i.width;
        if (i.height > i.width) ratio = bound / i.height;
        if ( ratio > 1 ) ratio = 1
        var w = i.width * ratio
        var h = i.height * ratio

        return { width: w, height: h, ratio: ratio }
    },

    Event: {
        append: function(message) {
            new Insertion.Bottom('chat-data-tbody', '<tr class="chat-event"><td colspan="3">' + message + '</td></tr>');
            Chatroom.scrollToBottom();
        },

        userLeave: function() {
        }
    },
    ping: function() {
        new Ajax.Request("/chatrooms/" + Chatroom.info.id + "/ping")
    }
}

Chatroom = new Chatroom();

if ( typeof String.prototype.trim == 'undefined' ) {
    String.prototype.trim = function() {
        return this.replace(/^\s+/, "").replace(/\s+$/,"");
    }
}

// Juggernaut Overrides

$(document).observe("juggernaut:connected", function () {
    new Ajax.Request('/chatrooms/' + Chatroom.info.id + '/join', {
        asynchronous: true,
        evalScripts:true
    });
    Chatroom.Event.append("[INFO] Connected to juggernaut push server")
    Chatroom.Event.append("Chatroom subject updated")
});


window.onunload =  function() {
    if (Chatroom.info) {
        new Ajax.Request('/chatrooms/' + Chatroom.info.id + '/leave', {                
                asynchronous: false
            });
    }
};

