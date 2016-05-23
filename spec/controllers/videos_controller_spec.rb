require 'spec_helper'

describe VideosController do
  describe 'GET show' do
    it 'sets up @video for authenticated user' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      get :show, id: video.id
      expect(assigns(:video)).to eq(video)
    end

    it 'sets up @reviews for authenticated user' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      review1 = Fabricate(:review, video: video)
      review2 = Fabricate(:review, video: video)
      get :show, id: video.id
      expect(assigns(:reviews)).to include(review1, review2)
    end

    it 'redirects to sign_in_path for unauthenticated user' do
      video = Fabricate(:video)
      get :show, id: video.id
      expect(response).to redirect_to sign_in_path
    end
  end

  describe 'GET search' do
    context 'for authenticated users' do
      before do
        session[:user_id] = Fabricate(:user).id
      end

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

    it 'redirects to sign_in_path for unauthenticated user' do
      get :search, search_text: 'something'
      expect(response).to redirect_to sign_in_path
    end
  end
end
