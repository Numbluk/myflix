require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:full_name) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:queue_items).order('position') }
  it { should have_many(:invitations) }

  describe '#video_in_queue?' do
    let(:user) { Fabricate(:user) }
    let(:video) { Fabricate(:video) }

    it 'should return true when the user has the video in queue' do
      Fabricate(:queue_item, video: video, user: user)
      expect(user.video_in_queue?(video)).to eq(true)
    end

    it 'should return false when the user does not have video in queue' do
      Fabricate(:queue_item, user: user)
      expect(user.video_in_queue?(video)).to eq(false)
    end
  end

  describe '#follows?' do
    it 'returns true if the user has a following relationship with another user' do
      dave = Fabricate(:user)
      hal = Fabricate(:user)
      relationship = Fabricate(:relationship, leader: hal, follower: dave)
      expect(dave.follows?(hal)).to be true
    end

    it 'return false if the user does not have a following relationship with another user' do
      dave = Fabricate(:user)
      hal = Fabricate(:user)
      relationship = Fabricate(:relationship, leader: dave, follower: hal)
      expect(dave.follows?(hal)).to be false
    end
  end

  describe '#follow' do
    it 'makes a user follow another user' do
      dave = Fabricate(:user)
      hal = Fabricate(:user)
      dave.follow(hal)
      expect(dave.follows?(hal)).to be true
    end
  end

  describe '#generate_token' do
    it 'generates a random string' do
      user = Fabricate(:user)
      user.generate_token
      expect(user.token).to be_present
    end
  end

  describe '#remove_token' do
    it 'removes the token' do
      user = Fabricate(:user)
      user.generate_token
      user.remove_token
      expect(user.token).to be_nil
    end
  end
end
