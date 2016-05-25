require 'spec_helper'

describe QueueItem do
  it { should belong_to(:video) }
  it { should belong_to(:user) }

  describe '#video_title' do
    it 'returns the title of the associated video' do
      video = Fabricate(:video, title: 'South Park')
      queue_item = Fabricate(:queue_item, video: video)

      expect(queue_item.video_title).to eq('South Park')
    end
  end

  describe '#rating' do
    let(:user) { Fabricate(:user) }
    let(:video) { Fabricate(:video) }
    let(:queue_item) { Fabricate(:queue_item, user: user, video: video) }

    it 'returns the rating of the review when the review is present' do
      review = Fabricate(:review, rating: 5, video: video, user: user)

      expect(queue_item.rating).to eq(review.rating)
    end

    it 'returns nil when the rating of the review is not present' do
      expect(queue_item.rating).to eq(nil)
    end
  end

  describe '#category_name' do
    it 'returns the category name of the video' do
      category = Fabricate(:category, name: 'comedies')
      video = Fabricate(:video, category: category)
      queue_item = Fabricate(:queue_item, video: video)
      expect(queue_item.category_name).to eq("comedies")
    end
  end

  describe '#category' do
    it 'returns the category of the video' do
      category = Fabricate(:category, name: 'comedies')
      video = Fabricate(:video, category: category)
      queue_item = Fabricate(:queue_item, video: video)
      expect(queue_item.category).to eq(category)
    end
  end

  describe '#position_cannot_be_less_than_one' do
    it 'raises an error if position is less than 1' do
      expect{Fabricate(:queue_item, position: 0)}.to raise_error
    end

    it 'does not raise an error if position is nil' do
      expect{Fabricate(:queue_item, position: nil)}.not_to raise_error
    end
  end

  describe '#position_cannot_be_greater_than_queue_items_count' do
    it 'raises an error if position is greater than number of QueueItems' do
      expect{Fabricate(:queue_item, position: 1000)}.to raise_error
    end

    it 'does not raise an error if position is nil' do
      expect{Fabricate(:queue_item, position: nil)}.not_to raise_error
    end

    it 'does not raise an error if item does not already exist' do
      expect{Fabricate(:queue_item)}.not_to raise_error
    end
  end
end
