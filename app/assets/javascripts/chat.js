(function($){
  $(document).ready(function() {
    socket = new WebSocket('ws://localhost/chat');

    socket.onmessage = function(event) {
      $('div#output').append(event.data + '<br>')
    };

    $('input#input').keypress(function(event) {
      if(event.which == 13) {
        var input = $(this);

        socket.send(input.val());
        input.val(null);
      }
    });
  });
})($);