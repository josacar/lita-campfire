module Lita
  module Adapters
    class Campfire < Adapter
      class Callback
        def initialize(robot)
          @robot = robot
        end

        def room_message(room)
          room.listen do |m|
            text    = m.body
            user    = get_user(m.user)
            source  = Source.new(user, room)
            message = Message.new(@robot, text, source)
            @robot.receive message
          end
        end

        private
        def get_user(user_data)
          if user_data
            user_id = user_data.id
            User.new(user_id, user_data)
          else
            User.new(-1)
          end
        end
      end
    end
  end
end
