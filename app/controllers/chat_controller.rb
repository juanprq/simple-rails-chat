class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      connection = Bunny.new
      connection.start
      channel = connection.create_channel

      # public working queue
      public_queue = channel.queue 'chat-public-queue'

      # when the socket receives a message, publish to rabbit
      tubesock.onmessage do |message|
        request        = JSON.parse message
        queue_out_name = "#{request['email']}-out"
        queue_in_name  = "#{request['email']}-in"

        queue_in  = channel.queue queue_in_name
        queue_out = channel.queue queue_out_name

        # check the type
        case request['type']
        when 'open'
          # send to the public queue
          request.merge! ({
            type:      'subscribe',
            queue_out: queue_out_name,
            queue_in:  queue_in_name,
            agent:     '+573113412790',
          })

          # create and subscribe to the in queue
          queue_in.subscribe block: false do |delivery_info, properties, body|
            # send the messages to the chat window
            values = JSON.parse body
            message = "#{values['name']}: #{values['message']}"
            tubesock.send_data message
          end

          # ask cli consumer to subscribe to queues
          public_queue.publish request.to_json
          # send message to the user
          queue_in.publish({name: 'Server', message: 'connected'}.to_json)
        when 'message'
          # when the chat window sends a message, send to the cli
          queue_out.publish message
        end
      end

      # if the socket closes the connection
      tubesock.onclose do
        # TODO: if the connection it's closed send message to the agent.
        connection.close
      end
    end
  end

end