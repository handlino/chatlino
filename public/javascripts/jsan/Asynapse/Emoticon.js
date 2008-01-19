if ( typeof Asynapse == 'undefined' ) {
    Asynapse = {}
}

Asynapse.Emoticon = function(){}

Asynapse.Emoticon.VERSION = "0.01"

Asynapse.Emoticon.prototype = {
    filter: function(target) {
        if ( typeof target == 'string' ) {
            return this.filter_text(target)
        }
        if ( typeof target == 'object' && target.nodeType == 1 ) {
            return this.filter_element(target)
        }
    },
    filter_text: function(text) {
        var self = this;
        return text.replace(this.pattern(), function(icon) {
            return self.do_filter(icon)
        });
    },
    filter_element: function(elem) {
        var self = this;
        for ( var i = 0; i < elem.childNodes.length; i++ ) {
            if ( elem.childNodes[i].nodeType == 3 ) {
                var range = elem.ownerDocument.createRange()
                range.selectNode( elem.childNodes[i] )
                var docfrag = range.createContextualFragment( this.filter_text(elem.childNodes[i].nodeValue) )
                elem.replaceChild(docfrag, elem.childNodes[i]);
            }
        }
    },
    do_filter: function(icon) {
        var xhtml = this.config.xhtml ? " /" : ""
        var img_class = this.config["class"] ?
            ' class="' + this.config["class"] + '"' : ""

        return "<img src=\""
            + this.config.imgbase + "/"
            + this.map[icon]
            + '" '
            + img_class
            + xhtml
            + '>'
    },
    pattern: function () {
        if ( !this._pattern ) {
            var icons = [];
            for(i in this.map) {
                icons.push( this.quotemeta(i) )
            }
            this._pattern = new RegExp( "(" + icons.join("|") +")"  ,"g")
        }
        return this._pattern
    },
    quotemeta: function ( str ) {
        var safe = str;
        var bs=String.fromCharCode(92);  
        var unsafe= bs + "|-.+*?[^]$(){}=!<>¦:";  
        for ( i=0; i<unsafe.length; ++i ){  
            safe = safe.replace(new RegExp("\\"+unsafe.charAt(i),"g"),
                                bs + unsafe.charAt(i));
        }
        return safe;
    }
}

Asynapse.Emoticon.GoogleTalk = new Asynapse.Emoticon();

Asynapse.Emoticon.GoogleTalk.config = {
        'imgbase' : "http://mail.google.com/mail/help/images/screenshots/chat",
        'xhtml'   : 1,
        'strict'  : 0,
        'class'   : null
}

Asynapse.Emoticon.GoogleTalk.map = {
        "<3" : "heart.gif",
        ":(|)" : "monkey.gif",
        "\\m/" : "rockout.gif",
        ":-o" : "shocked.gif",
        ":D" : "grin.gif",
        ":(" : "frown.gif",
        "X-(" : "angry.gif",
        "B-)" : "cool.gif",
        ":'(" : "cry.gif",
        "=D" : "equal_grin.gif",
        ";)" : "wink.gif",
        ":-|" : "straightface.gif",
        "=)" : "equal_smile.gif",
        ":-D" : "nose_grin.gif",
        ";^)" : "wink_big_nose.gif",
        ";-)" : "wink_nose.gif",
        ":-)" : "nose_smile.gif",
        ":-/" : "slant.gif",
        ":P" : "tongue.gif"
}

Asynapse.Emoticon.MSN = new Asynapse.Emoticon();

Asynapse.Emoticon.MSN.config = {
        'imgbase' : "http://messenger.msn.com/Resource/emoticons",
        'xhtml'   : 1,
        'strict'  : 0,
        'class'   : null
}

Asynapse.Emoticon.MSN.map = {
        ':-)' : "regular_smile.gif",
        ':)' : "regular_smile.gif",
        ':-D' : "teeth_smile.gif",
        ':d' : "teeth_smile.gif",
        ':-O' : "omg_smile.gif",
        ':o' : "omg_smile.gif",
        ':-P' : "tongue_smile.gif",
        ':p' : "tongue_smile.gif",
        ';-)' : "wink_smile.gif",
        ';)' : "wink_smile.gif",
        ':-(' : "sad_smile.gif",
        ':(' : "sad_smile.gif",
        ':-S' : "confused_smile.gif",
        ':s' : "confused_smile.gif",
        ':-|' : "what_smile.gif",
        ':|' : "what_smile.gif",
        ':\'(' : "cry_smile.gif",
        ':-$' : "red_smile.gif",
        ':$' : "red_smile.gif",
        '(H)' : "shades_smile.gif",
        '(h)' : "shades_smile.gif",
        ':-@' : "angry_smile.gif",
        ':@' : "angry_smile.gif",
        '(A)' : "angel_smile.gif",
        '(a)' : "angel_smile.gif",
        '(6)' : "devil_smile.gif",
        ':-#' : "47_47.gif",
        '8o|' : "48_48.gif",
        '8-|' : "49_49.gif",
        '^o)' : "50_50.gif",
        ':-*' : "51_51.gif",
        '+o(' : "52_52.gif",
        ':^)' : "71_71.gif",
        '*-)' : "72_72.gif",
        '<:o)' : "74_74.gif",
        '8-)' : "75_75.gif",
        '|-)' : "77_77.gif",
        '(C)' : "coffee.gif",
        '(c)' : "coffee.gif",
        '(Y)' : "thumbs_up.gif",
        '(y)' : "thumbs_up.gif",
        '(N)' : "thumbs_down.gif",
        '(n)' : "thumbs_down.gif",
        '(B)' : "beer_mug.gif",
        '(b)' : "beer_mug.gif",
        '(D)' : "martini.gif",
        '(d)' : "martini.gif",
        '(X)' : "girl.gif",
        '(x)' : "girl.gif",
        '(Z)' : "guy.gif",
        '(z)' : "guy.gif",
        '({)' : "guy_hug.gif",
        '(})' : "girl_hug.gif",
        ':-[' : "bat.gif",
        ':[' : "bat.gif",
        '(^)' : "cake.gif",
        '(L)' : "heart.gif",
        '(l)' : "heart.gif",
        '(U)' : "broken_heart.gif",
        '(u)' : "broken_heart.gif",
        '(K)' : "kiss.gif",
        '(k)' : "kiss.gif",
        '(G)' : "present.gif",
        '(g)' : "present.gif",
        '(F)' : "rose.gif",
        '(f)' : "rose.gif",
        '(W)' : "wilted_rose.gif",
        '(w)' : "wilted_rose.gif",
        '(P)' : "camera.gif",
        '(p)' : "camera.gif",
        '(~)' : "film.gif",
        '(@)' : "cat.gif",
        '(&)' : "dog.gif",
        '(T)' : "phone.gif",
        '(t)' : "phone.gif",
        '(I)' : "lightbulb.gif",
        '(i)' : "lightbulb.gif",
        '(8)' : "note.gif",
        '(S)' : "moon.gif",
        '(*)' : "star.gif",
        '(E)' : "envelope.gif",
        '(e)' : "envelope.gif",
        '(O)' : "clock.gif",
        '(o)' : "clock.gif",
        '(M)' : "messenger.gif",
        '(m)' : "messenger.gif",
        '(sn)' : "53_53.gif",
        '(bah)' : "70_70.gif",
        '(pl)' : "55_55.gif",
        '(||)' : "56_56.gif",
        '(pi)' : "57_57.gif",
        '(so)' : "58_58.gif",
        '(au)' : "59_59.gif",
        '(ap)' : "60_60.gif",
        '(um)' : "61_61.gif",
        '(ip)' : "62_62.gif",
        '(co)' : "63_63.gif",
        '(mp)' : "64_64.gif",
        '(st)' : "66_66.gif",
        '(li)' : "73_73.gif",
        '(mo)' : "69_69.gif"
}

Asynapse.Emoticon.Yahoo = new Asynapse.Emoticon();

Asynapse.Emoticon.Yahoo.config = {
        'imgbase' : "http://us.i1.yimg.com/us.yimg.com/i/mesg/emoticons6",
        'xhtml'   : 1,
        'strict'  : 0,
        'class'   : null
}

Asynapse.Emoticon.Yahoo.map = {
        ':)'   : '1.gif',
        ':('   : '2.gif',
        ';)'   : '3.gif',
        ':D'   : '4.gif',
        ';;)'  : '5.gif',
        '>:D<' : '6.gif',
        ':-/'  : '7.gif',
        ':x'   : '8.gif',
        ':">'  : '9.gif',
        ':P'   : '10.gif',
        ':-*'  : '11.gif',
        '=(('  : '12.gif',
        ':-O'  : '13.gif',
        'X('   : '14.gif',
        ':>'   : '15.gif',
        'B-)'  : '16.gif',
        ':-S'  : '17.gif',
        '#:-S' : '18.gif',
        '>:)'  : '19.gif',
        ':(('  : '20.gif',
        ':))'  : '21.gif',
        ':|'   : '22.gif',
        '/:)'  : '23.gif',
        '=))'  : '24.gif',
        'O:)'  : '25.gif',
        ':-B'  : '26.gif',
        '=;'   : '27.gif',
        'I-|'  : '28.gif',
        '8-|'  : '29.gif',
        'L-)'  : '30.gif',
        ':-&'  : '31.gif',
        ':-$'  : '32.gif',
        '[-('  : '33.gif',
        ':O)'  : '34.gif',
        '8-}'  : '35.gif',
        '<:-P' : '36.gif',
        '(:|'  : '37.gif',
        '=P~'  : '38.gif',
        ':-?'  : '39.gif',
        '#-o'  : '40.gif',
        '=D>'  : '41.gif',
        ':-SS' : '42.gif',
        '@-)'  : '43.gif',
        ':^o'  : '44.gif',
        ':-w'  : '45.gif',
        ':-<'  : '46.gif',
        '>:P'  : '47.gif',
        '<):)' : '48.gif',
        ':@)'  : '49.gif',
        '3:-O' : '50.gif',
        ':(|)' : '51.gif',
        '~:>'  : '52.gif',
        '@};-' : '53.gif',
        '%%-'  : '54.gif',
        '**==' : '55.gif',
        '(~~)' : '56.gif',
        '~O)'  : '57.gif',
        '*-:)' : '58.gif',
        '8-X'  : '59.gif',
        '=:)'  : '60.gif',
        '>-)'  : '61.gif',
        ':-L'  : '62.gif',
        '[-O<' : '63.gif',
        '$-)'  : '64.gif',
        ':-"'  : '65.gif',
        'b-('  : '66.gif',
        ':)>-' : '67.gif',
        '[-X'  : '68.gif',
        '\:D/' : '69.gif',
        '>:/'  : '70.gif',
        ';))'  : '71.gif',
        ':-@'  : '76.gif',
        '^:)^' : '77.gif',
        ':-j'  : '78.gif',
        '(*)'  : '79.gif'
}
