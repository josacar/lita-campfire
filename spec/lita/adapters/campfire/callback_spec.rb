require 'spec_helper'

describe Campfire::Callback do

  class DummyRoom < Struct.new(:id, :message, :users)
    def listen
      yield message
    end
  end

  let(:campfire_message) { double }
  let(:campfire_user)    { { id: 1, name: 'Bender Bending Rodriguez' } }
  let(:message)          { double('Message') }
  let(:robot)            { double('Robot', mention_name: 'Robot') }
  let(:room)             { DummyRoom.new(1, campfire_message, users) }
  let(:source)           { double('Source') }
  let(:text)             { "Yes it's the apocalypse alright. I always though is have a hand in it." }
  let(:user)             { double('User') }
  let(:users)            { [ {id: 2, name: 'Bender'}, {id: 3, name: 'Washbucket'} ] }

  subject { described_class.new(robot, room) }

  describe '#listen' do
    %w( TextMessage PasteMessage ).each do |message_type|
      describe "with a #{message_type}" do
        let(:campfire_message) { double(
          type: message_type,
          body: text,
          user: campfire_user) }

        it 'passes the message to Robot#receive' do
          expect(Lita::User).to receive(:create).with(1, name: 'Bender Bending Rodriguez').and_return(user)
          expect(Lita::Source).to receive(:new).with(user, '1').and_return(source)
          expect(Lita::Message).to receive(:new).with(robot, text, source).and_return(message)
          expect(robot).to receive(:receive).with(message)
          subject.listen
        end
      end
    end

    describe 'EnterMessage' do
      let(:campfire_message) { double(
        type: 'EnterMessage',
        user: campfire_user) }

      it 'creates a user' do
        expect(Lita::User).to receive(:create).with(1, name: 'Bender Bending Rodriguez').and_return(user)
        subject.listen
      end
    end

  end

  describe '#register_users' do
    it 'creates a user for all the users in the room' do
      users.each do |user|
        user_id = user[:id]
        name    = user[:name]
        expect(Lita::User).to receive(:create).with(user_id, name: name)
      end
      subject.register_users
    end
  end

end
