module Lita
  module Adapters
    class Campfire < Adapter
      class Connector
        def initialize(robot, opts)
          @robot     = robot
          @subdomain = opts.fetch(:subdomain)
          @apikey    = opts.fetch(:apikey)
          @rooms     = opts.fetch(:rooms)
          @debug     = opts.fetch(:debug) { false }
        end

        def connect
          @campfire = Tinder::Campfire.new(@subdomain, token: @apikey)
        end

        def join_rooms
          rooms.each do |room_id|
            room = fetch_room(room_id)
            room.join
            callback = Callback.new(@robot, room)
            callback.register_users
            callback.listen
          end
        end

        def send_messages(room_id, messages)
          fetch_room(room_id).tap do |my_room|
            messages.each do |message|
              if message.include?("\n")
                my_room.paste message
              else
                my_room.speak message
              end
            end
          end
        end

        def disconnect
          Lita.logger.info("Disconnecting from Campfire.")
          rooms.each do |room_id|
            room = fetch_room(room_id)
            room.leave
          end
        end

        private

        attr_reader :rooms

        def fetch_room(room_id)
          @campfire.find_room_by_id(room_id).tap do |room|
            if room.nil?
              raise RoomNotAvailable,
                "Make sure you have access to room #{ room_id.inspect }"
            end
          end
        end
      end
    end
  end
end