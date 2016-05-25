require 'spec_helper'

describe VideosController do
  describe 'GET show' do
    let(:video) { Fabricate(:video) }
    before { set_current_user }

    it 'sets up @video for authenticated user' do
      get :show, id: video.id
      expect(assigns(:video)).to eq(video)
    end

    it 'sets up @reviews for authenticated user' do
      review1 = Fabricate(:review, video: video)
      review2 = Fabricate(:review, video: video)
      get :show, id: video.id
      expect(assigns(:reviews)).to include(review1, review2)
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { get :show, id: video.id }
    end
  end

  describe 'GET search' do
    context 'for authenticated users' do
      before { set_current_user }

      it 'sets up @search_text' do
        search_text = 'south park'
        get :search, search_text: search_text
        expect(assigns(:search_text)).to eq(search_text)
      end

      it 'sets up @videos based on @search_text' do
        Fabricate(:video, title: 'South Park')
        Fabricate(:video, title: 'Southside')
        get :search, search_text: 'south'
        expect(assigns(:videos).length).to eq(2)
      end
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { get :search, search_text: 'something' }
    end
  end
end
