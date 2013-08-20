require 'spec_helper'

describe Campfire::Connector do
  let(:robot) { double }
  let(:subdomain) { 'mycampfire' }
  let(:apikey) { '2e9f45bb934c0fa13e9f19ee0901c316fda9fc1' }
  let(:rooms) { %w( 12345 41234 ) }
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
    describe 'when I have access to the room' do
      let(:room) { double('Room', id: 666) }

      before do
        allow(campfire).to receive(:find_room_by_id).and_return(room)
        subject.connect
      end

      it 'joins each room' do
        expect(Campfire::Callback).to receive(:new).
          with(robot).
          and_return(callback = double('Callback'))
        expect(callback).to receive(:room_message).with(room)

        expect(room).to receive(:join)

        subject.join_rooms [ double ]
      end
    end

    describe "when I don't have access to the room" do
      before do
        allow(campfire).to receive(:find_room_by_id).and_return(nil)
        subject.connect
      end

      it 'raises an exception' do
        expect { subject.join_rooms [ double ] }.to raise_error(Campfire::RoomNotAvailable)
      end
    end
  end

  describe '#send_messages' do
    let(:message) { "I'm gonna drink 'til I reboot." }

    let(:room) { double }

    before do
      allow(campfire).to receive(:find_room_by_id).and_return(room)
      subject.connect
    end

    it 'speaks each message into room' do
      expect(room).to receive(:speak).with(message)
      subject.send_messages double(id: 1), [ message ]
    end
  end
end
