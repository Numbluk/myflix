require 'spec_helper'

describe Category do
  it 'saves itself' do
    category = Category.new(name: 'drama')
    category.save
    expect(category.name).to eq(Category.first.name)
  end

  it 'has many videos' do
    video = Video.new(title: 'Warcraft')
    video.save

    category = Category.new(name: 'action')
    category.save
    category.videos << video

    expect(category.videos).to include(video)
  end

  it { should have_many(:videos) }

  describe '#recent_videos' do
    it 'returns the six in reverse created_at' do
      drama = Category.create(name: 'drama')
      first = Video.create(title: 'Warcraft', description: 'First', category: drama)

      6.times { Video.create(title: 'foo', description: 'movie', category: drama) }

      expect(drama.recent_videos).not_to include(first)
    end

    it 'returns 6 movies if there are more than 6' do
      drama = Category.create(name: 'drama')
      7.times { Video.create(title: 'Warcraft', description: 'movie', category: drama) }

      expect(drama.recent_videos.count).to eq(6)
    end

    it 'returns all the movies if there are less than six movies' do
      drama = Category.create(name: 'drama')
      Video.create(title: 'Warcraft', description: 'First', category: drama)
      Video.create(title: 'Warcraft II', description: 'Second', category: drama)
      Video.create(title: 'Warcraft III', description: 'Third', category: drama)

      expect(drama.recent_videos.count).to eq(3)
    end

    it 'returns an empty array if no recent movies' do
      drama = Category.create(name: 'drama')
      expect(drama.recent_videos).to eq([])
    end
  end
end
