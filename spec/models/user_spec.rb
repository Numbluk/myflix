
require 'spec_helper'

describe User do
  it { should validate_presence_of(:email) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:full_name) }
  it { should validate_uniqueness_of(:email) }
  it { should have_many(:queue_items).order('position') }

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
end
