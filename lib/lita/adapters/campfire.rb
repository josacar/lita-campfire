module Lita
  module Adapters
    class Campfire < Adapter
      require_configs :subdomain, :apikey, :rooms

      attr_reader :connector

      def initialize(robot)
        super

        @connector = Connector.new(
          robot,
          subdomain: config.subdomain,
          apikey: config.apikey,
          rooms: rooms,
          debug: config.debug,
          tinder: config.tinder
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
          Lita.config.adapter
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