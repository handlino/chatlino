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
/*
  Compile using MTACS (http://www.mtasc.org/)
  mtasc -version 8 -strict -header 1:1:1 -main -swf juggernaut.swf juggernaut.as
  
*/

import flash.external.ExternalInterface;
//import flash.system.Security;

class SocketServer {
  
  static var socket : XMLSocket;
  
  static function connect() {
    // Create new XMLSocket object
    System.security.loadPolicyFile('xmlsocket://' + _root.host + ':' + _root.port);
    socket = new XMLSocket();
    socket.connect(_root.host, _root.port);
    socket.onXML = newXML;
    socket.onConnect = onConnect;
    socket.onClose = onDisconnect;
  }
  
  static function onConnect(success:Boolean) {
    if (success) {
      socket.send('{"broadcast":0,"ses_id":"' + _root.ses_id + '","unique_id":"' + _root.unique_id + '","channels":[' + unescape(_root.channels) + ']}');
      socket.send("\n");
      getURL("javascript:Juggernaut.connected()");
    } else {
      getURL("javascript:Juggernaut.errorConnecting()");
    }
  }
  
  static function onDisconnect() {
    getURL("javascript:Juggernaut.disconnected()");
  }
  
  static function newXML(input:XML) {
    ExternalInterface.call("receiveData", input.toString());
  }
  
  static function main() {
    connect();
  }
  
}

