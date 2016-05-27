require 'spec_helper'

describe QueueItem do
  it { should belong_to(:video) }
  it { should belong_to(:user) }
  it { should validate_numericality_of(:position) }

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
      expect(queue_item.category_name).to eq('comedies')
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
end
