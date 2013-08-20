module Lita
  module Adapters
    class Campfire < Adapter
      class Connector
        def initialize(robot, opts, campfire_interface = Tinder::Campfire)
          @robot     = robot
          @subdomain = opts.fetch(:subdomain)
          @apikey    = opts.fetch(:apikey)
          @rooms     = opts.fetch(:rooms)
          @debug     = opts.fetch(:debug) { false }

          @campfire_interface = campfire_interface
        end

        def connect
          @campfire = @campfire_interface.new(@subdomain, token: @apikey)
        end

        def join_rooms(rooms)
          @campfire.rooms.select {|room| in_room?(room) }.each do |room|
            room.join
            Callback.new(@robot).room_message(room)
          end
        end

        def send_messages(room, messages)
          @campfire.find_room_by_id(room.id).tap do |my_room|
            messages.each do |message|
              my_room.speak message
            end
          end
        end

        private
        def in_room?(room)
          @rooms.include?(room.id.to_s)
        end
      end
    end
  end
end
