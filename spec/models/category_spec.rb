require 'spec_helper'

describe Category do
  it { should have_many(:videos) }
  it { should validate_presence_of(:name) }

  describe '#recent_videos' do
    let(:drama) { Category.create(name: 'drama') }

    it 'returns the six in reverse created_at' do
      first = Fabricate(:video, category: drama)
      Fabricate.times(6, :video, category: drama)

      expect(drama.recent_videos).not_to include(first)
    end

    it 'returns 6 movies if there are more than 6' do
      Fabricate.times(7, :video, category: drama)
      expect(drama.recent_videos.count).to eq(6)
    end

    it 'returns all the movies if there are less than six movies' do
      Fabricate.times(3, :video, category: drama)

      expect(drama.recent_videos.count).to eq(3)
    end

    it 'returns an empty array if no recent movies' do
      expect(drama.recent_videos).to eq([])
    end
  end
end
