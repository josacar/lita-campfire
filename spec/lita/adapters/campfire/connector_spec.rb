require 'spec_helper'

describe Campfire::Connector, lita: true do
  let(:robot) { instance_double(Lita::Robot) }
  let(:robot_id) { 2 }
  let(:subdomain) { 'mycampfire' }
  let(:apikey) { '2e9f45bb934c0fa13e9f19ee0901c316fda9fc1' }
  let(:rooms) { %w( 12345 ) }
  let(:options) { { subdomain: subdomain, apikey: apikey, rooms: rooms } }
  let(:campfire) { instance_double(Tinder::Campfire) }
  let(:room) { instance_double(Tinder::Room) }

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

  context 'when connected to campfire' do
    before do
      allow(campfire).to receive(:find_room_by_id).and_return(room)
      subject.connect
    end
    let(:callback) { instance_double(Campfire::Callback) }

    describe '#disconnect' do
      it "leaves joined rooms" do
        expect(room).to receive(:leave)
        subject.disconnect
      end
    end

    describe 'when tinder options are set' do
      let(:tinder_options) { { timeout: 30 } }
      let(:options) do
        {
          subdomain: subdomain,
          apikey: apikey,
          rooms: rooms,
          tinder_options: tinder_options
        }
      end

      it 'passes options to underlying tinder lib' do
        allow(campfire).to receive(:find_room_by_id).and_return(room)
        subject.connect
        allow(campfire).to receive_message_chain(:me,:id).and_return(robot_id)
        allow(Campfire::Callback).to receive(:new).and_return(callback)

        allow(room).to receive(:join)
        allow(callback).to receive(:register_users)
        expect(callback).to receive(:listen).with(tinder_options)
        subject.join_rooms
      end
    end

    describe '#join_rooms' do
      describe 'when I have access to the room' do
        it 'joins each room, registers the users and listens for messages' do
          allow(campfire).to receive_message_chain(:me,:id).and_return(robot_id)
          expect(Campfire::Callback).to receive(:new).
            with(robot: robot, room: room, robot_id: robot_id).
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
        end

        it 'raises an exception' do
          expect { subject.join_rooms }.to raise_error(Campfire::RoomNotAvailable)
        end
      end
    end

    describe '#send_messages' do
      context 'with a one line message' do
        let(:message) { "I'm gonna drink 'til I reboot." }

        it 'speaks each message into room' do
          expect(room).to receive(:speak).with(message)
          subject.send_messages room, [ message ]
        end
      end

      context 'with a multi line message' do
        let(:message) { "I'm gonna drink 'til I reboot.\nNow I'm too drunk" }

        it 'pastes each message into room' do
          expect(room).to receive(:paste).with(message)
          subject.send_messages room, [ message ]
        end
      end
    end

    describe '#set_topic' do
      let(:topic) { 'Let it be wadus' }

      it 'sets toom topic' do
        expect(room).to receive(:topic=).with(topic)
        subject.set_topic(room, topic)
      end
    end
  end
end