JSAN.use("DOM.Events");

if ( typeof Widget == "undefined" )
    Widget = {};

Widget.Lightbox = function(param) {
    this.init(param);
    return this;
}

Widget.Lightbox.VERSION = '0.09';
Widget.Lightbox.EXPORT = [];
Widget.Lightbox.EXPORT_OK = [];
Widget.Lightbox.EXPORT_TAGS = {};

(function(){
    var ua = navigator.userAgent;
    Widget.Lightbox.Browser = { 
        IE:     !!(window.attachEvent && !window.opera), 
        Opera:  !!window.opera, 
        WebKit: ua.indexOf('AppleWebKit/') > -1, 
        Gecko:  ua.indexOf('Gecko') > -1 && ua.indexOf('KHTML') == -1 
    };
    Widget.Lightbox.prototype.browser = Widget.Lightbox.Browser
})();

Widget.Lightbox.showing = 0;

Widget.Lightbox.show = function(param) {
    if ( typeof param == 'string' ) {
        param = { content: param }
    }

    var box = new Widget.Lightbox(param);
    box.show();
    return box;
}

Widget.Lightbox.prototype.init = function(param) {
    this.win = window;
    this.doc = window.document;
    this.config = {
        clickBackgroundToHide: true,
        backgroundColor: "#000",
        backgroundOpacity: 0.7,
        width: "500px",
        margin: "100px auto 0 auto"
    };
    this._callbacks = {}

    if ( param ) {
        if ( param.content )
            this.content(param.content);
 
        if ( param.divs ) {
            this.divs(param.divs);
            this.div = this._divs.wrapper;
            this.div.style.display="none";
        }
        if ( param.effects ) {
            this.effects(param.effects);
        }
        if ( param.callbacks ) {
            this.callbacks(param.callbacks)
        }
    }
    return this;
}

Widget.Lightbox.prototype.show = function() {
    if ( Widget.Lightbox.showing ) {
        return;
    }
    Widget.Lightbox.showing++;
    
    var div = this.create();
    if ( this.div.style.display== "none" )
        this.div.style.display="block";
    this.applyStyle();
    this.applyHandlers();
    this.applyEffects();

    if ( typeof this._callbacks.show == 'function' ) {
        var self = this;
        this._callbacks.show(self);
    }
}

Widget.Lightbox.prototype.hide = function() {
    if (this.div.parentNode) {
        this.div.style.display="none";
        if (this.browser.IE) {
            document.body.scroll="yes"
        }
        if ( typeof this._callbacks.hide == 'function' ) {
            this._callbacks.hide(this);
        }

        Widget.Lightbox.showing--;
    }
}

Widget.Lightbox.prototype.content = function(content) {
    if ( typeof content != 'undefined' ) {
        this._content = content;
    }
    return this._content;
}

Widget.Lightbox.prototype.divs = function(divs) {
    if ( typeof this._divs == 'undefined' ) this._divs = {}
    if ( typeof divs != 'undefined' ) {
        for(var i in divs) {
            this._divs[i] = divs[i]
        }
    }
    return this._divs
}

Widget.Lightbox.prototype.callbacks = function(callbacks) {
    if ( typeof this._callbacks ) this._callbacks = {}
    if ( typeof callbacks != 'undefined' ) {
        for(var i in callbacks) {
            this._callbacks[i] = callbacks[i]
        }
    }
    return this._callbacks
}

Widget.Lightbox.prototype.create = function() {
    if (typeof this.div != 'undefined') {
        return this.div;
    }
    
    var wrapperDiv = this.doc.createElement("div");
    wrapperDiv.className = "jsan-widget-lightbox";

    var contentDiv = this.doc.createElement("div");
    contentDiv.className = "jsan-widget-lightbox-content";
    if ( typeof this._content == 'object' ) {
        if ( this._content.nodeType && this._content.nodeType == 1 ) {
            contentDiv.appendChild( this._content );
        }
    }
    else {
        contentDiv.innerHTML = this._content;
    }

    var contentWrapperDiv = this.doc.createElement("div");
    contentDiv.className = "jsan-widget-lightbox-content-wrapper";

    var bgDiv = this.doc.createElement("div");
    bgDiv.className = "jsan-widget-lightbox-background";

    contentWrapperDiv.appendChild(contentDiv);

    wrapperDiv.appendChild(bgDiv);
    wrapperDiv.appendChild(contentWrapperDiv);
    
    this.div = wrapperDiv;
    this._divs = {
        wrapper: wrapperDiv,
        background: bgDiv,
        content: contentDiv,
        contentWrapper: contentWrapperDiv
    };
    wrapperDiv.style.display = "none";
    this.doc.body.appendChild(wrapperDiv);
    return this.div;
}

Widget.Lightbox.prototype.applyStyle = function() {
    var baseZ =  999998;
    var divs = this._divs;
    with(divs.wrapper.style) {
        if ( this.browser.IE ) {
            position='absolute';
        }
        else {
            position='fixed';
        }
        top=0;
        left=0;
        width='100%';
        height='100%';
        padding=0;
        margin=0;
    }
    with(divs.background.style) {
        background=this.config.backgroundColor;
        opacity=this.config.backgroundOpacity;

        if ( this.browser.IE || this.browser.WebKit ) {
            position='absolute';
            filter="alpha(opacity="+ (this.config.backgroundOpacity * 100) + ")";
            top=0;
            left=0;
        }
        else {
            position='fixed';
        }
        width="100%";
        height="100%";
        zIndex=baseZ;
        padding=0;
        margin=0;
    }
    with(divs.contentWrapper.style) {
        zIndex=baseZ + 1;
        background='#fff';
        padding=0;
        margin=this.config.margin;
        width=this.config.width;
        border="1px outset #555";
        if ( this.browser.IE ) {
            position='absolute';
            top=0;
            left=0;
        }
        else {
            position='fixed';
        }        
    }

    with(divs.content.style) {
        margin='5px';
    }
   
    var win_height = document.body.clientHeight;
    var win_width = document.body.clientWidth;
    var my_width = divs.content.offsetWidth;
    var my_left = (win_width - my_width) /2;
    my_left = (my_left < 0)? 0 : my_left + "px";
    
    divs.contentWrapper.style.left = my_left;
    if( this.browser.IE ) {
        document.body.scroll="no";
        divs.background.style.height = win_height;
    }
}

Widget.Lightbox.prototype.applyHandlers = function(){
    if(!this.div)
        return;

    var self = this;

    if ( this.config.clickBackgroundToHide == true ) {
        DOM.Events.addListener(this._divs.background, "click", function () {
            self.hide();
        });
    }
    if ( this.browser.IE ) {
        DOM.Events.addListener(window, "resize", function () {
            self.applyStyle();
        });
    }
}

Widget.Lightbox.prototype.effects = function() {
    if ( arguments.length > 0 ) {
        if ( typeof arguments[0] == 'Array' ) {
            this.effects.apply(this, arguments[0]);
        }
        else {
            this._effects = [];
            for (var i=0; i<arguments.length; i++) {
                this._effects.push(arguments[i]);
            }
        }
    }
    return this._effects;
}

Widget.Lightbox.prototype.applyEffects = function() {
    if (!this._effects)
        return;
    for (var i=0;i<this._effects.length;i++) {
        this.applyEffect(this._effects[i]);
    }
}

Widget.Lightbox.prototype.applyEffect = function(effect) {
    var func_name = "applyEffect" + effect;
    if ( typeof this[func_name] == 'function') {
        this[func_name]();
    }
}

// Require Effect.RoundedCorners
Widget.Lightbox.prototype.applyEffectRoundedCorners = function() {
    divs = this._divs
    if ( ! divs ) { return; }
    if ( typeof Effect.RoundedCorners == 'undefined' ) { return; }
    divs.contentWrapper.style.border="none";
    var bs = divs.contentWrapper.getElementsByTagName("b");
    for (var i = 0; i < bs.length; i++) {
        if(bs[i].className.match(/rounded-corners-/)) {
            return;
        }
    }
    for (var i=1; i< 5; i++) {
        Effect.RoundedCorners._Styles.push([
            ".rounded-corners-" + i,
            "opacity: 0.7",
            "filter: alpha(opacity=70)"
        ]);
    }

    Effect.RoundedCorners._addStyles();
    Effect.RoundedCorners._roundCorners(
        divs.contentWrapper,
        {
            'top': true,
            'bottom':true,
            'color':'black'
        }
    );
}

// A Generator function for scriptaculous effects.
;(function () {
    var effects = ['Appear', 'Grow', 'BlindDown', 'Shake'];
    for (var i=0; i<effects.length; i++) {
        var name = "applyEffect" + effects[i];
        Widget.Lightbox.prototype[name] = function(effect) {
            return function() {
                if ( ! this._divs ) { return; }
                if ( typeof Effect[effect] == 'undefined' ) { return; }
                if (effect != 'Shake') 
                    this._divs.contentWrapper.style.display="none";
                Effect[effect](this._divs.contentWrapper, { duration: 2.0 });
            }
        }(effects[i]);
    }
})();

