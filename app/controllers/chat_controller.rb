class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      connection = Bunny.new
      connection.start
      channel = connection.create_channel
      fanout = nil

      # public working queue
      public_queue = channel.queue 'chat-public-queue'

      # when the socket receives a message, publish to rabbit
      tubesock.onmessage do |message|
        request = JSON.parse message

        # check the type
        case request['type']
        when 'open'
          # create de fanout
          fanout = channel.fanout request['email'], auto_delete: true

          queue = channel.queue('', :exclusive => true)
          queue.bind(fanout)
          queue.subscribe block: false do |delivery_info, properties, body|
            # send message to the client chat
            request = JSON.parse body

            message = "#{request['name']}: #{request['message']}"
            tubesock.send_data message
          end

          # send message to the user
          tubesock.send_data 'server: connected'

          # send to the public queue
          request = {
            type:    'subscribe',
            fanout:  fanout.name,
            agent:   '+573113412790',
            request: request
          }
          channel.default_exchange.publish(request.to_json, :routing_key => public_queue.name)
        when 'message'
          # simple message
          fanout.publish message
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