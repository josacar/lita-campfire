require 'spec_helper'

describe Campfire::Connector do
  let(:robot) { double }
  let(:subdomain) { 'mycampfire' }
  let(:apikey) { '2e9f45bb934c0fa13e9f19ee0901c316fda9fc1' }
  let(:rooms) { %w( 12345 ) }
  let(:options) { { subdomain: subdomain, apikey: apikey, rooms: rooms } }
  let(:campfire) { double }

  subject { described_class.new(robot, options) }

  before do
    allow(Tinder::Campfire).to receive(:new).and_return(campfire)
  end

  describe '#connect' do
    it 'connects the campfire connection' do
      expect(Tinder::Campfire).to receive(:new).with(subdomain, token: apikey)
      subject.connect
    end
  end

  describe '#join_rooms' do
    let(:callback) { double(:Callback) }
    let(:room) { double('Room', id: 666) }

    describe 'when I have access to the room' do

      before do
        allow(campfire).to receive(:find_room_by_id).and_return(room)
        subject.connect
      end

      it 'joins each room, registers the users and listens for messages' do
        expect(Campfire::Callback).to receive(:new).
          with(robot, room).
          and_return(callback)

        expect(room).to receive(:join)
        expect(callback).to receive(:listen)
        expect(callback).to receive(:register_users)

        subject.join_rooms
      end
    end

    describe "when I don't have access to the room" do
      before do
        allow(campfire).to receive(:find_room_by_id).and_return(nil)
        subject.connect
      end

      it 'raises an exception' do
        expect { subject.join_rooms }.to raise_error(Campfire::RoomNotAvailable)
      end
    end

    describe 'when tinder options are set' do
      let(:tinder_options) { { timeout: 30 } }
      let(:options) do
        {
          subdomain: subdomain,
          apikey: apikey,
          rooms: rooms,
          tinder: tinder_options
        }
      end

      it 'passes options to underlying tinder lib' do
        allow(campfire).to receive(:find_room_by_id).and_return(room)
        subject.connect
        allow(Campfire::Callback).to receive(:new).and_return(callback)

        allow(room).to receive(:join)
        allow(callback).to receive(:register_users)
        expect(callback).to receive(:listen).with(tinder_options)
        subject.join_rooms
      end
    end
  end

  describe '#send_messages' do
    let(:room) { double }

    before do
      allow(campfire).to receive(:find_room_by_id).and_return(room)
      subject.connect
    end

    context 'with a one line message' do
      let(:message) { "I'm gonna drink 'til I reboot." }

      it 'speaks each message into room' do
        expect(room).to receive(:speak).with(message)
        subject.send_messages double(id: 1), [ message ]
      end
    end

    context 'with a multi line message' do
      let(:message) { "I'm gonna drink 'til I reboot.\nNow I'm too drunk" }

      it 'pastes each message into room' do
        expect(room).to receive(:paste).with(message)
        subject.send_messages double(id: 1), [ message ]
      end
    end
  end

  describe '#disconnect' do
    let(:room) { double('Room', id: 666) }

    before do
      allow(campfire).to receive(:find_room_by_id).and_return(room)
      subject.connect
    end

    it "leaves joined rooms" do
      expect(room).to receive(:leave)
      subject.disconnect
    end
  end
end