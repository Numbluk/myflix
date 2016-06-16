require 'spec_helper'

describe Admin::VideosController do
  describe 'GET new' do
    it_behaves_like 'require_sign_in' do
      let(:action) { get :new }
    end

    it_behaves_like 'require_admin' do
      let(:action) { get :new }
    end

    it 'sets up @video' do
      set_current_admin
      get :new
      expect(assigns(:video)).to be_a_new(Video)
    end

    it 'sets up flash message for regular users' do
      set_current_user
      get :new
      expect(flash[:error]).to be_present
    end
  end

  describe 'POST create' do
    it_behaves_like 'require_admin' do
      let(:action) { post :create }
    end

    context 'with valid input' do
      it 'redirects to the new video page' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { title: 'Warcraft', description: 'Wonderful!', category_id: category.id }
        expect(response).to redirect_to new_admin_video_path
      end

      it 'creates a new video' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { title: 'Warcraft', description: 'Wonderful!', category_id: category.id }
        expect(category.videos.count).to eq(1)
      end

      it 'sets the flash success message' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { title: 'Warcraft', description: 'Wonderful!', category_id: category.id }
        expect(flash[:success]).to be_present
      end
    end

    context 'with invalid input' do
      it 'does not create a new video' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { description: 'Wonderful!', category_id: category.id }
        expect(category.videos.count).to eq(0)
      end

      it 'renders the :new template' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { description: 'Wonderful!', category_id: category.id }
        expect(response).to render_template :new
      end

      it 'sets a flash error message' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { description: 'Wonderful!', category_id: category.id }
        expect(flash[:error]).to be_present
      end

      it 'sets up a @video' do
        set_current_admin
        category = Fabricate(:category)
        post :create, video: { description: 'Wonderful!', category_id: category.id }
        expect(assigns(:video)).to be_present
      end
    end
  end
end
