(function($){
  $(document).ready(function() {

    var socket = new WebSocket('ws://localhost/operator-chat');

    socket.onmessage = function(event) {
      var requests = JSON.parse(event.data);

      var html = HandlebarsTemplates['chats_table']({requests: requests});
      $('div#requests').html(html);
    };

  });
})($);