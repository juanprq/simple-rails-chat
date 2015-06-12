class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      connection = Bunny.new
      connection.start
      channel = connection.create_channel
      fanout = nil

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
            tubesock.send_data body
          end
          fanout.publish 'server: connected'
        when 'message'
          # simple message
          message = "#{request['name']}: #{request['message']}"
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