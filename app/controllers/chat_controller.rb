class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      connection = Bunny.new
      connection.start
      channel = connection.create_channel
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
        # channel.default_exchange.publish(message, :routing_key => queue.name)
        fanout.publish message
      end

      # if the socket closes the connection
      tubesock.onclose do
        connection.close
      end
    end
  end

end