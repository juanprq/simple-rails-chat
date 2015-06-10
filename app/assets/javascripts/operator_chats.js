(function($){
  $(document).ready(function() {

    var socket = new WebSocket('ws://localhost/operator-chat');

    socket.onmessage = function(event) {
      console.log(event.data);
    };

  });
})($);