require 'spec_helper.rb'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the user that is logged in' do
      user = Fabricate(:user)
      session[:user_id] = user.id
      queue_item1 = Fabricate(:queue_item, user: user)
      queue_item2 = Fabricate(:queue_item, user: user)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it 'redirects users who are not logged in' do
      session[:user_id] = nil
      get :index
      expect(response).to redirect_to sign_in_path
    end
  end

  describe 'POST create' do
    it 'redirects to the my queue page' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(response).to redirect_to my_queue_path
    end

    it 'creates a queue item' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it 'creates a queue item associated with the video' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it 'creates a queue item associated with the signed in user' do
      session[:user_id] = Fabricate(:user).id
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.user.id).to eq(session[:user_id])
    end

    it 'adds the queue item as the last position' do
      user = Fabricate(:user)
      session[:user_id] = user.id
      video1 = Fabricate(:video)
      Fabricate(:queue_item, video: video1, user: user)
      video2 = Fabricate(:video)
      post :create, video_id: video2.id
      video2_queue_item = QueueItem.find_by(user: user, video: video2)
      expect(video2_queue_item.position).to eq(2)
    end

    it 'does not add the queue item more than once if already added' do
      user = Fabricate(:user)
      session[:user_id] = user.id
      video = Fabricate(:video)
      Fabricate(:queue_item, video: video, user: user)
      post :create, video_id: video.id
      post :create, video_id: video.id
      expect(QueueItem.where(user: user, video: video).count).to eq(1)
    end

    it 'redirects to the sign in page for unauthenticated users' do
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(response).to redirect_to sign_in_path
    end
  end

  describe '#destroy' do
    it 'redirects to the my queue page' do
      user = Fabricate(:user)
      session[:user_id] = user.id
      queue_item = Fabricate(:queue_item, user: user)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to my_queue_path
    end

    it 'deletes the queue item' do
      user = Fabricate(:user)
      session[:user_id] = user.id
      queue_item = Fabricate(:queue_item, user: user)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it 'does not delete the queue item if the current user is not the owner of that queue item' do
      hal = Fabricate(:user)
      session[:user_id] = hal.id
      dave = Fabricate(:user)
      daves_queue_item = Fabricate(:queue_item, user: dave)
      delete :destroy, id: daves_queue_item.id
      expect(QueueItem.count).to eq(1)
    end

    it 'redirects to the sign in page for unauthenticated users' do
      session[:user_id] = nil
      delete :destroy, id: 1
      expect(response).to redirect_to sign_in_path
    end
  end
end
