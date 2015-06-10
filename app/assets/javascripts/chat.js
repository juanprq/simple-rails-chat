(function($){

  var organizationToken = 'BTqCf5dM1bVS07aTZcp8sbihx2TjFZiV',
    info = {
      token: organizationToken,
      name: 'Juan Pablo Ramrez',
      email: 'juan.ramirez.q@gmail.com',
      phone: '3113412790'
    };

  $(document).ready(function() {
    var socket = new WebSocket('ws://localhost/chat');

    socket.onmessage = function(event) {
      $('div#output').append(event.data + '<br>')
    };

    socket.onopen = function() {
      var request = {
        type: 'connect',
        id: '1',
        info: info
      };
      socket.send(JSON.stringify(request));
    };

    $('input#input').keypress(function(event) {
      if(event.which == 13) {
        var input = $(this),
          data = {
            info: info,
            message: input.val()
          };

        socket.send(JSON.stringify(data));
        input.val(null);
      }
    });
  });
})($);