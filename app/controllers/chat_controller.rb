class ChatController < ApplicationController
  include Tubesock::Hijack

  def connection

    hijack do |tubesock|
      public_queue_name = 'chat-public-queue'
      thread = nil
      connection = nil

      # when the socket receives a message, publish to rabbit
      tubesock.onmessage do |message|
        request        = JSON.parse message

        email = request['email'].gsub('.', '_dot_').gsub('@', 'at')
        queue_out_name = "#{email}_out"
        queue_in_name  = "#{email}_in"

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

          connection = Beaneater.new('localhost:11300')

          # connection.jobs.register queue_in_name do |job|
          #   values = JSON.parse job
          #   message = "#{values['name']}: #{values['message']}"
          #   tubesock.send_data message
          # end
          thread = Thread.new do
            connection.tubes.watch! queue_in_name

            while true
              job = connection.tubes[queue_in_name].reserve

              values = JSON.parse job.body
              message = "#{values['name']}: #{values['message']}"
              tubesock.send_data message
              job.delete
            end
          end

          connection.tubes[public_queue_name].put request.to_json
          connection.tubes[queue_in_name].put({name: 'Server', message: 'connected'}.to_json)
        when 'message'
          # when the chat window sends a message, send to the cli
          connection = Beaneater.new('localhost:11300')
          connection.tubes[queue_out_name].put message
          puts message
          connection.close
        end
      end

      # if the socket closes the connection
      tubesock.onclose do
        # TODO: if the connection it's closed send message to the agent.
        thread.kill if thread
        connection.close if connection
      end
    end
  end

end