module Lita
  module Adapters
    class Campfire < Adapter
      class Callback

        MESSAGE_TYPES = %w( TextMessage PasteMessage ).freeze

        def initialize(robot)
          @robot = robot
        end

        def room_message(room)
          room.listen do |m|
            if MESSAGE_TYPES.include?(m.type)
              text    = m.body
              user    = create_user(m.user)
              source  = Source.new(user, room.id.to_s)
              message = Message.new(@robot, text, source)
              @robot.receive message
            end
          end
        end

        private
        def create_user(user_data)
          user_id = user_data.delete(:id)
          User.create(user_id, user_data)
        end

      end
    end
  end
end
