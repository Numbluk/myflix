require 'spec_helper.rb'

describe Video do
  it 'saves itself' do
    video = Video.new(title: 'Warcraft', description: 'A movie with a fantasy world.')
    video.save

    Video.first.title.should == 'Warcraft'
  end

  it 'belongs to a category' do
    category = Category.create(name: 'drama')
    video = Video.create(title: 'A Beautiful Mind', category: category)

    expect(video.category).to eq(category)
  end

  it 'does not save a video without a title' do
    Video.create(description: 'cool movie')
    expect(Video.count).to eq(0)
  end

  it 'does not save a video without a description' do
    Video.create(title: 'Harry Potter')
    expect(Video.count).to eq(0)
  end

  it { should belong_to(:category) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should have_many(:reviews).order('created_at DESC') }

  describe '#search_by_title' do
    it 'returns empty array if no videos are found' do
      expect(Video.search_by_title('stuff')).to eq([])
    end

    it 'returns 1 video in an array if an exact match is found' do
      video = Video.create(title: 'South Park', description: 'Kidzzz')
      expect(Video.search_by_title('South Park')[0]).to eq(video)
    end

    it 'returns 1 video in an array if a partial match is found' do
      video = Video.create(title: 'South Park', description: 'Kidzzz')
      expect(Video.search_by_title('South')[0]).to eq(video)
    end

    it 'returns multiple videos as an array if a title is matched' do
      warcraft = Video.create(title: 'Warcraft', description: 'Fantasy world.')
      war_of_worlds = Video.create(title: 'War of the Worlds', description: 'Crazy psychiatrist.')

      expect(Video.search_by_title('War')).to include(warcraft, war_of_worlds)
    end

    it 'ignores case when searching' do
      video = Video.create(title: 'Warcraft', description: 'Fantasy world')

      expect(Video.search_by_title('war')).to include(video)
    end

    it 'returns multiple videos as an array and ordered by created_at' do
      warcraft = Video.create(title: 'Warcraft', description: 'Fantasy world.')
      war_of_worlds = Video.create(title: 'War of the Worlds', description: 'Crazy psychiatrist.')

      expect(Video.search_by_title('War')).to eq([war_of_worlds, warcraft])
    end

    it 'returns emptry array if search term is blank' do
      expect(Video.search_by_title('')).to eq([])
    end
  end
end
