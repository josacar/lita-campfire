module Lita
  module Adapters
    class Campfire < Adapter
      namespace 'campfire'

      config :subdomain, type: String, required: true
      config :apikey, type: String, required: true
      config :rooms, type: Array, required: true

      config :debug, type: [TrueClass, FalseClass], default: false
      config :tinder_options, type: Hash, default: {}

      attr_reader :connector

      def initialize(robot)
        super

        options = {
          subdomain: config.subdomain,
          apikey: config.apikey,
          rooms: rooms,
          debug: config.debug,
          tinder_options: config.tinder_options
        }

        @connector = Connector.new(
          robot,
          options
        )
      end

      def run
        connector.connect
        connector.join_rooms
        sleep
      rescue Interrupt
        disconnect
      end

      def send_messages(target, messages)
        connector.send_messages(target.room, messages)
      end

      def set_topic(target, topic)
        connector.set_topic(target.room, topic)
      end

      def shut_down
        disconnect
      end

      private

      def config
        Lita.config.adapters.campfire
      end

      def rooms
        Array(config.rooms)
      end

      def disconnect
        connector.disconnect
      end
    end

    Lita.register_adapter(:campfire, Campfire)
  end
end
