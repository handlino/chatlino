Ipush = {
    // Config need to be loaded from an ipush_auth action
    config: {},

    // Live Handler Storage
    onSubjectMessage: [],
    onStatus: [],

    init: function(params) {
        if ( !params.profile ) {
            alert("Must define \"profile\" in the params of Ipush.init()")
        }
        Ipush.params = $H(params);

        $w("SubjectMessage Status").each(
            function(ev) {
                if ( typeof params["on" + ev] == 'function' ) {
                    Ipush["on" + ev].push(params["on" + ev])
                }
            }
        )
    },
    connect: function() {
        var tries = 0;
        var c = function() {
            try {
                if (tries > 100) {
                    if ( typeof Ipush.params.onFailure == 'function' ) {
                        Ipush.params.onFailure()
                    }
                    return;
                }
                iplink.mypjax.init();
                var ipush = Ipush.config[Ipush.params.profile];
                iplink.connect(
                    ipush.server,
                    ipush.port,
                    ipush.group,
                    ipush.product,
                    ipush.user,
                    ipush.password
                );
            } catch(e) {
                setTimeout(c, 50);
                tries++;
            }
        }
        new Ajax.Request("/chatroom/ipush_auth", {
            onComplete: function(t) {
                var m = utf8to16(decode64(t.responseText))
                eval(m);
                c();
            }})
    },
    send: function(data) {
        if ( iplink ) {
            iplink.sendNPSubject( Chatroom.info.channel, data )
        }
    }
}

// Ipush/Pjax Interfaces.
function onSubjectMessage(sbj, len, msg) {
    if(Ipush.onSubjectMessage) {
        Ipush.onSubjectMessage.each( function( h ) { h(sbj, len, msg) })
    }
}

function onStatus(status, msg) {
    Ipush.onStatus.each( function( h ) {
        h(status, msg)
    })
}

// This code was written by Tyler Akins and has been placed in the
// public domain.  It would be nice if you left this header intact.
// Base64 code from Tyler Akins -- http://rumkin.com
function decode64(input) {
    var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    var output = "";
    var chr1, chr2, chr3;
    var enc1, enc2, enc3, enc4;
    var i = 0;

   // remove all characters that are not A-Z, a-z, 0-9, +, /, or =
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

    do {
        enc1 = keyStr.indexOf(input.charAt(i++));
        enc2 = keyStr.indexOf(input.charAt(i++));
        enc3 = keyStr.indexOf(input.charAt(i++));
        enc4 = keyStr.indexOf(input.charAt(i++));

        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;

        output = output + String.fromCharCode(chr1);

        if (enc3 != 64) {
            output = output + String.fromCharCode(chr2);
        }
        if (enc4 != 64) {
            output = output + String.fromCharCode(chr3);
        }
    } while (i < input.length);

    return output;
}

function utf8to16(str) {
    var out, i, len, c;
    var char2, char3;

    out = "";
    len = str.length;
    i = 0;
    while(i < len) {
        c = str.charCodeAt(i++);
        switch(c >> 4)
    {
        case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
            // 0xxxxxxx
        out += str.charAt(i-1);
        break;
        case 12: case 13:
            // 110x xxxx   10xx xxxx
        char2 = str.charCodeAt(i++);
        out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
        break;
        case 14:
            // 1110 xxxx  10xx xxxx  10xx xxxx
        char2 = str.charCodeAt(i++);
        char3 = str.charCodeAt(i++);
        out += String.fromCharCode(((c & 0x0F) << 12) |
                                   ((char2 & 0x3F) << 6) |
                                   ((char3 & 0x3F) << 0));
        break;
    }
    }

    return out;
}

