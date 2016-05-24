require 'spec_helper'

describe ReviewsController do
  describe 'POST create' do
    context 'with authorized user' do
      before do
        session[:user_id] = Fabricate(:user).id
      end

      context 'with valid input' do
        before do
          post :create, video_id: video.id, review: Fabricate.attributes_for(:review)
        end

        let (:video) { Fabricate(:video) }

        it 'creates an association with logged in user' do
          expect(Review.first.user_id).to eq(session[:user_id])
        end

        it 'creates the review' do
          expect(Review.count).to eq(1)
        end

        it 'creates an association with the current video' do
          expect(Video.first.id).to eq(video.id)
        end

        it 'gives a notice of success' do
          expect(flash[:notice]).not_to be_empty
        end

        it 'redirects to video path' do
          expect(response).to redirect_to video_path(video)
        end
      end

      context 'with invalid input' do
        let (:video) { Fabricate(:video) }

        it 'does not create the review' do
          post :create, video_id: video.id, review: { content: '', rating: 5 }
          expect(Review.count).to eq(0)
        end

        it 'sets up @video' do
          post :create, video_id: video.id, review: { content: '', rating: 5 }
          expect(assigns(:video)).to eq(video)
        end

        it 'renders the video template' do
          post :create, video_id: video.id, review: { content: '', rating: '' }
          expect(response).to render_template 'videos/show'
        end
      end
    end

    context 'with unauthorized user' do
      it 'redirects to sign in path when attempt to create review' do
        session[:user_id] = nil
        post :create, video_id: Fabricate(:video).id
        expect(response).to redirect_to sign_in_path
      end
    end

  end
end
