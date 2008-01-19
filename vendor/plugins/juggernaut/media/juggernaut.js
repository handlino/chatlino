/*
Copyright (c) 2006 Alexander MacCaw
Copyright (c) 2006 Michael Schuerig

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


var Juggernaut = {

  debug: true,
  verbose_debug: false,
  
  isIE: /Microsoft/i.test(navigator.appName),
  
  hasFirebug: "console" in window && "firebug" in window.console && window.console.firebug.indexOf("1.0") > -1,
  
  logFunc: function(msg) { Juggernaut.hasFirebug ? console.log("Juggernaut: " + msg) : window.alert("Juggernaut: " + msg) },

  listenToChannels: function(options) {
    Juggernaut._setupOptions(options);
    Event.observe(window, 'load', function() {      
      Juggernaut._appendFlashObject();
    });
  },

  receiveData: function(data) {
    if(Juggernaut.base64){
     var decodedData = Juggernaut._decode64(data);
     Juggernaut._verbose_log("Received data:\n" + decodedData);
     eval(Juggernaut._utf8to16(decodedData));
    } else {
     Juggernaut._verbose_log("Received data:\n" + data);
     eval(data);
    }
  },

  connected: function () {
    Juggernaut._verbose_log('You have been connected');
  },

  errorConnecting: function() {
    Juggernaut._log('There has been an error connection, please check the push server and make sure your firewall has the correct ports open');
  },

  disconnected: function() {
    Juggernaut._log('Connection has been lost. Please log out and log back in for chat and collaborative functionality.');
  },

  _setupOptions: function(options) {
    Juggernaut.host = options['host'] || 'localhost';
    Juggernaut.port = options['port'] || 443;
    Juggernaut.ses_id = options['ses_id'];
    Juggernaut.num_tries = options['num_tries'];
    Juggernaut.num_secs = options['num_secs'];
    Juggernaut.unique_id = options['unique_id'] || null;
    Juggernaut.base64 = options['base64'] || false;
    
    var data = ''
    if (options['channel']) {
      data = '"' + options['channel'] + '"';
    } else if (options['channels']) {
      data = options['channels'].map(function(c) { return '"' + c + '"' }).join(',');
    }
    Juggernaut.channels = encodeURIComponent(data);
  },

  _appendFlashObject: function() {
    var so = new SWFObject("/juggernaut.swf", "juggernaut_flash", "1", "1", "8", "#ffffff");
    so.useExpressInstall('/expressinstall.swf');
    so.addVariable("host", Juggernaut.host);
    so.addVariable("port", Juggernaut.port);
    so.addVariable("channels", Juggernaut.channels);
    so.addVariable("ses_id", Juggernaut.ses_id);
    so.addVariable("num_tries", Juggernaut.num_tries);
    so.addVariable("num_secs", Juggernaut.num_secs);
    so.addVariable("unique_id", Juggernaut.unique_id);
    so.write("flashcontent");
  },

  _log: function(msg) {
    if (Juggernaut.debug) {
      Juggernaut.logFunc(msg);
    }
  },
  
  _verbose_log: function(msg) {
      if (Juggernaut.verbose_debug) {
        Juggernaut.logFunc(msg);
      }
  },
 
 _decode64: function(input) {
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
  },
  
  _utf8to16: function(str) {
    var out, i, len, c;
    var char2, char3;
  
    out = "";
    len = str.length;
    i = 0;
    while(i < len) {
      c = str.charCodeAt(i++);
      switch(c >> 4) { 
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
  
};

function receiveData(d){
 Juggernaut.receiveData(d);
}