module Lita
  module Adapters
    class Campfire < Adapter
      require_configs :subdomain, :apikey, :rooms
      OPTIONAL_CONFIG_OPTIONS = %i(debug tinder_options)

      attr_reader :connector

      def initialize(robot)
        super

        options = {
          subdomain: config.subdomain,
          apikey: config.apikey,
          rooms: rooms,
        }

        options.merge!(optional_config_options)

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
          Lita.config.adapter
      end

      def rooms
        Array(config.rooms)
      end

      def disconnect
        connector.disconnect
      end

      def optional_config_options
        OPTIONAL_CONFIG_OPTIONS.inject({}) do |options,config_option|
          config_option_value = config.public_send(config_option)
          options.merge!(config_option => config_option_value) if config_option_value
          options
        end
      end
    end

    Lita.register_adapter(:campfire, Campfire)
  end
end