/*-------------------------------------------------------------------------------------------------------------------------------------------------
pjax(R) library from ICE Technology Corp.
-------------------------------------------------------------------------------------------------------------------------------------------------*/
if(typeof(icetech) == "undefined") var icetech = new Object();
if(typeof(icetech.util) == "undefined") icetech.util = new Object();
if(typeof(icetech.iPush2Link) == "undefined") icetech.iPush2Link = new Object();

icetech.iPush2Link = function() {
    document.write('<div id="ip_link"></div>');
    this.mypjax = new Object();
    var fo = new SWFObject("/javascripts/pjax/pjax.swf", "icepjax", "1", "1", "8", "#FFFFFF");
    fo.write("ip_link");
    var isIE = navigator.appName.indexOf("Microsoft") != -1;
    this.mypjax = (isIE) ? window['icepjax'] : document['icepjax'];
    setTimeout('pjChkReady()', 100);
}

icetech.iPush2Link.prototype = {
    initPjax: function() {
        if ((typeof(this.mypjax) == "undefined") ||  this.mypjax == null) {
            var isIE = navigator.appName.indexOf("Microsoft") != -1;
            this.mypjax = (isIE) ? window['icepjax'] : document['icepjax'];
            if ((typeof(this.mypjax) == "undefined") ||  this.mypjax == null) {
                throw("Fail to init pjax.");
            }
        }
    },
    
    getProperty: function(prop) {
        this.initPjax();
        return this.mypjax.fpGetProperty(prop);
    },
    
    setProperty: function(prop, val) {
        this.initPjax();
        this.mypjax.fpSetProperty(prop, val);
    },

    connect: function(a, b, c, d, e, f) {
        this.initPjax();
        this.mypjax.fpConnect(a, b, c, d, e, f);
    },

    disconnect: function() {
        this.initPjax();
        this.mypjax.fpDisconnect();
    },

    subChannel: function(ch) {
        this.initPjax();
        this.mypjax.fpSubChannel(ch);
    },

    unsubChannel: function(ch) {
        this.initPjax();
        this.mypjax.fpUnsubChannel(ch);
    },

    sendChannel: function(ch, msg) {
        this.initPjax();
        this.mypjax.fpSendChannel(ch, msg);
    },
    
    subSubject: function(sbj) {
        this.initPjax();
        this.mypjax.fpSubSubject(sbj);
    },

    unsubSubject: function(sbj) {
        this.initPjax();
        this.mypjax.fpUnsubSubject(sbj);
    },

    subDSubject: function(sbj, dname) {
        this.initPjax();
        this.mypjax.fpSubDSubject(sbj, dname);
    },

    unsubDSubject: function(sbj, dname) {
        this.initPjax();
        this.mypjax.fpUnsubDSubject(sbj, dname);
    },
    
    sendPSubject:function(sbj, msg) {
        this.initPjax();
        this.mypjax.fpSendPSubject(sbj, msg);
    },
    
    sendNPSubject:function(sbj, msg) {
        this.initPjax();
        this.mypjax.fpSendNPSubject(sbj, msg);
    },
    
    sendPQueue:function(sbj, msg) {
        this.initPjax();
        this.mypjax.fpSendPQueue(sbj, msg);
    },
    
    sendNPQueue:function(sbj, msg) {
        this.initPjax();
        this.mypjax.fpSendNPQueue(sbj, msg);
    }
}

var iPush2Link = icetech.iPush2Link;

function pjChkReady() {
    var mpjax;
    var isIE = navigator.appName.indexOf("Microsoft") != -1;
    mpjax = (isIE) ? window['icepjax'] : document['icepjax'];

    if ((typeof(mpjax) == "undefined") ||  (mpjax == null)) {
        setTimeout('pjChkReady()', 100);
        return;
    }
    if ((typeof(mpjax.init) == "undefined") ||  (mpjax.init == null)) {
        setTimeout('pjChkReady()', 100);
        return;
    }
    mpjax.init();
}

function pjStatus(err, msg) {
    if (typeof(onStatus) == "function") {
        onStatus(err, msg);
    }
}

