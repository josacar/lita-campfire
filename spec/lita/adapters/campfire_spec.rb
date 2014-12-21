require 'spec_helper'

describe Lita::Adapters::Campfire, lita: true do
  before do
    registry.register_adapter(:campfire, described_class)

    registry.configure do |config|
      config.adapters.campfire.subdomain = 'foodomain'
      config.adapters.campfire.apikey = 'fooapikey'
      config.adapters.campfire.rooms = ['fooroom']
    end

    allow(described_class::Connector).to receive(:new).and_return(connector)
  end

  subject { described_class.new(robot) }

  let(:robot) { Lita::Robot.new(registry) }
  let(:connector) { instance_double(Lita::Adapters::Campfire::Connector) }

  it "registers with Lita" do
    expect(Lita.adapters[:campfire]).to eql(described_class)
  end

  it 'can receive hash with tinder options' do
    tinder_options = { timeout: 30, auto_reconnect: false }
    Lita.configure do |config|
      config.adapters.campfire.tinder_options = tinder_options
    end

    expect(described_class::Connector).to receive(:new).with(robot, hash_including(:tinder_options => tinder_options))
    subject
  end

  describe '#run' do
    before do
      allow(subject.connector).to receive(:connect)
      allow(subject.connector).to receive(:join_rooms)
      allow(subject).to receive(:sleep)
    end

    it 'connects to campfire' do
      expect(subject.connector).to receive(:connect)
      subject.run
    end

    it 'join specified rooms' do
      rooms = ['room1', 'room2']
      Lita.config.adapter.rooms = rooms
      expect(subject.connector).to receive(:join_rooms)
      subject.run
    end

    it "sleeps the main thread" do
      expect(subject).to receive(:sleep)
      subject.run
    end

    it "disconnects gracefully on interrupt" do
      expect(subject).to receive(:disconnect)
      allow(subject).to receive(:sleep).and_raise(Interrupt)
      subject.run
    end
  end

  describe '#send_messages' do
    it 'sends messages to rooms' do
      source = instance_double(Lita::Source, room: "room_id")
      expect(subject.connector).to receive(:send_messages).with(
        'room_id',
        ["Hello!"]
      )
      subject.send_messages(source, ["Hello!"])
    end
  end

  describe "#set_topic" do
    it "sets a new topic for a room" do
      source = instance_double(Lita::Source, room: "room_id")
      expect(subject.connector).to receive(:set_topic).with(
        "room_id",
        "Topic"
      )
      subject.set_topic(source, "Topic")
    end
  end

  describe "#shut_down" do
    it "shuts down the connector" do
      expect(subject.connector).to receive(:disconnect)
      subject.shut_down
    end
  end
end
