(function($){
  $(document).ready(function() {
    var socket,
      name,
      email,
      url = 'ws://' + window.location.host + '/chat';

    // bind the interactions
    $('button#start-chat').click(function(event) {
      event.preventDefault();
      socket = new WebSocket(url);

      socket.onopen = function() {
        // build information
        name = $('input#name').val();
        email = $('input#email').val();

        var request = {
          type: 'open',
          name: name,
          email: email
        };

        // connect the chat and send first message
        socket.send(JSON.stringify(request));
      };

      socket.onmessage = function(event) {
        var chatDiv = $('div#output');
        chatDiv.append(event.data + '<br>');

        // scroll bottom of the div
        chatDiv.animate({
          scrollTop: chatDiv.prop('scrollHeight')
        });
      };

      $('div#information-form').fadeOut(function() {
        $('div#chat').fadeIn();
      });
    });

    var sendData = function() {
      var input = $('input#input'),
        request = {
        type: 'message',
        name: name,
        email: email,
        message: input.val()
      };

      socket.send(JSON.stringify(request));
      input.val(null);
    };

    $('input#input').keypress(function(event) {
      if(event.which == 13) {
        event.preventDefault();
        sendData();
      }
    });

    $('button#send').click(function(event) {
      event.preventDefault();
      sendData();
    });

    // socket = new WebSocket('ws://' + window.location.host + '/chat');

    // socket.onmessage = function(event) {
    //   $('div#output').append(event.data + '<br>')
    // };

    // $('input#input').keypress(function(event) {
    //   if(event.which == 13) {
    //     var input = $(this);

    //     socket.send(input.val());
    //     input.val(null);
    //   }
    // });
  });
})($);