class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      # create a thread to maintain the connection with the client.
      chat_thread = Thread.new do

        # subscribe to redis
        Redis.new.subscribe 'chat' do |on|

          # when redis receive a message, send the message to the socket
          on.message do |channel, message|
            tubesock.send_data message
          end
        end
      end

      # when the socket receives a message, publish to redis
      tubesock.onmessage do |message|
        values = JSON.parse message

        # search the organization
        organization_token = values['info']['token']
        organization = Organization.find_by_token organization_token

        if organization and values['type'] == 'connect'
          request = Request.new
          request.name = values['info']['name']
          request.status = :open
          request.token = values['id']
          request.organization = organization
          request.save

          redis = Redis.new
          redis.publish organization.token, 'update'
        end
      end

      # if the socket closes the connection, kill the thread
      tubesock.onclose do
        chat_thread.kill
      end
    end
  end

end