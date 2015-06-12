class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      connection = Bunny.new
      connection.start
      channel = connection.create_channel

      # TODO: this is going to be a dynamic name
      fanout = channel.fanout 'chat'

      tubesock.onopen do
        queue = channel.queue('', :exclusive => true)
        queue.bind(fanout)
        queue.subscribe block: false do |delivery_info, properties, body|
          tubesock.send_data body
        end
      end

      # when the socket receives a message, publish to rabbit
      tubesock.onmessage do |message|
        request = JSON.parse message

        # check the type
        case request['type']
        when 'open'
          # TODO:
          # check for agents, and assign them, subscribe to the fanout.
          fanout.publish 'server: connected'
        when 'message'
          # simple message
          message = "#{request['name']}: #{request['message']}"
          fanout.publish message
        end
      end

      # if the socket closes the connection
      tubesock.onclose do
        connection.close
      end
    end
  end

end