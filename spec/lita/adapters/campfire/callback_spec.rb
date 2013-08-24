require 'spec_helper'

describe Campfire::Callback do

  class DummyRoom < Struct.new(:message)
    def listen
      yield message
    end
  end

  let(:campfire_user) { { id: 1, name: 'Bender Bending Rodriguez' } }
  let(:message) { double('Message') }
  let(:robot) { double('Robot', mention_name: 'Robot') }
  let(:room) { DummyRoom.new(campfire_message) }
  let(:source) { double('Source') }
  let(:text) { "Yes it's the apocalypse alright. I always though is have a hand in it." }
  let(:user) { double('User') }

  subject { described_class.new(robot) }

  describe '#room_message' do
    %w( TextMessage PasteMessage ).each do |message_type|
      describe "with a #{message_type}" do
        let(:campfire_message) { double(
          type: message_type,
          body: text,
          user: campfire_user) }

        it 'passes the message to Robot#receive' do
          expect(Lita::User).to receive(:new).with(1, name: 'Bender Bending Rodriguez').and_return(user)
          expect(Lita::Source).to receive(:new).with(user, room).and_return(source)
          expect(Lita::Message).to receive(:new).with(robot, text, source).and_return(message)
          expect(robot).to receive(:receive).with(message)
          subject.room_message(room)
        end
      end
    end
  end

end
