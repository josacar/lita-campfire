module Lita
  module Adapters
    class Campfire < Adapter
      class Callback

        attr_reader :robot, :room

        def initialize(robot, room)
          @robot = robot
          @room  = room

          @receivers = [MessageReceiver, EnterReceiver].map do |receiver_type|
            receiver_type.new(self)
          end
        end

        def listen(options={})
          Thread.new do
            @room.listen(options) do |event|
              receive event
            end
          end
        end

        def register_users
          @room.users.each do |user|
            create_user user
          end
        end

        def create_user(user_data)
          user_data = user_data.dup
          user_id = user_data.delete(:id)
          User.create(user_id, user_data)
        end

        def receive(event)
          Thread.new do
            @receivers.each do |receiver|
              receiver.receive event
            end
          end
        end

        class EventReceiver

          class << self
            attr_accessor :message_types

            def receives(*types)
              self.message_types = types
            end
          end

          def initialize(callback)
            @callback = callback
            @robot    = callback.robot
            @room     = callback.room
          end

          def receive(event)
           _receive(event) if receives?(event)
          end

          private

          def receives?(event)
            self.class.message_types.include?(event.type)
          end
        end

        class MessageReceiver < EventReceiver

          receives 'TextMessage', 'PasteMessage'

          def _receive(event)
            text    = event.body
            user    = @callback.create_user(event.user)
            source  = Source.new(user: user, room: event.room_id.to_s)
            message = Message.new(@robot, text, source)
            @robot.receive message
          end

        end

        class EnterReceiver < EventReceiver

          receives 'EnterMessage'

          def _receive(event)
            @callback.create_user(event.user)
          end

        end

      end
    end
  end
end