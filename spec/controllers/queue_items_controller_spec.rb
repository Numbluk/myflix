require 'spec_helper.rb'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the user that is logged in' do
      user = Fabricate(:user)
      set_current_user(user)
      queue_item1 = Fabricate(:queue_item, user: user, position: 1)
      queue_item2 = Fabricate(:queue_item, user: user, position: 2)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { get :index }
    end

    it 'orders the queue items in ascending order by position' do
      user = Fabricate(:user)
      set_current_user(user)
      queue_item1 = Fabricate(:queue_item, user: user, position: 1)
      queue_item2 = Fabricate(:queue_item, user: user, position: 2)
      get :index
      expect(assigns(:queue_items)).to eq([queue_item1, queue_item2])
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
      set_current_user
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.count).to eq(1)
    end

    it 'creates a queue item associated with the video' do
      set_current_user
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.video).to eq(video)
    end

    it 'creates a queue item associated with the signed in user' do
      set_current_user
      video = Fabricate(:video)
      post :create, video_id: video.id
      expect(QueueItem.first.user.id).to eq(session[:user_id])
    end

    it 'adds the queue item as the last position' do
      user = Fabricate(:user)
      set_current_user(user)
      video1 = Fabricate(:video)
      Fabricate(:queue_item, video: video1, user: user)
      video2 = Fabricate(:video)
      post :create, video_id: video2.id
      video2_queue_item = QueueItem.find_by(user: user, video: video2)
      expect(video2_queue_item.position).to eq(2)
    end

    it 'does not add the queue item more than once if already added' do
      user = Fabricate(:user)
      set_current_user(user)
      video = Fabricate(:video)
      Fabricate(:queue_item, video: video, user: user)
      post :create, video_id: video.id
      post :create, video_id: video.id
      expect(QueueItem.where(user: user, video: video).count).to eq(1)
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { post :create, video_id: 3 }
    end
  end

  describe '#destroy' do
    it 'redirects to the my queue page' do
      user = Fabricate(:user)
      set_current_user(user)
      queue_item = Fabricate(:queue_item, user: user)
      delete :destroy, id: queue_item.id
      expect(response).to redirect_to my_queue_path
    end

    it 'deletes the queue item' do
      user = Fabricate(:user)
      set_current_user(user)
      queue_item = Fabricate(:queue_item, user: user)
      delete :destroy, id: queue_item.id
      expect(QueueItem.count).to eq(0)
    end

    it 'normalizes the remaining queue items' do
      dave = Fabricate(:user)
      set_current_user(dave)
      queue_item1 = Fabricate(:queue_item, user: dave, position: 1)
      queue_item2 = Fabricate(:queue_item, user: dave, position: 2)
      delete :destroy, id: queue_item1.id
      expect(QueueItem.first.position).to eq(1)
    end

    it 'does not delete the queue item if the current user is not the owner of that queue item' do
      hal = Fabricate(:user)
      set_current_user(hal)
      dave = Fabricate(:user)
      daves_queue_item = Fabricate(:queue_item, user: dave)
      delete :destroy, id: daves_queue_item.id
      expect(QueueItem.count).to eq(1)
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { delete :destroy, id: 1 }
    end
  end

  describe 'POST update_queues' do
    it_behaves_like 'require_sign_in' do
      let(:action) do
        post :update_queues, queue_items: [{ id: 2, position: 3 }, { id: 5, position: 2 }]
      end
    end

    context 'with valid input' do
      let(:dave) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: dave, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: dave, position: 2, video: video) }

      before do
        set_current_user(dave)
      end

      it 'redirects to my queue page' do
        post :update_queues, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]
        expect(response).to redirect_to my_queue_path
      end

      it 'reorders the queue items' do
        post :update_queues, queue_items: [{id: queue_item1.id, position: 2}, {id: queue_item2.id, position: 1}]

        expect(dave.queue_items).to eq([queue_item2, queue_item1])
      end

      it 'normalizes the position numbers' do
        post :update_queues, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2}]
        expect(dave.queue_items.map(&:position)).to eq([1, 2])
      end
    end

    context 'with invalid inputs' do
      let(:dave) { Fabricate(:user) }
      let(:video) { Fabricate(:video) }
      let(:queue_item1) { Fabricate(:queue_item, user: dave, position: 1, video: video) }
      let(:queue_item2) { Fabricate(:queue_item, user: dave, position: 2, video: video) }

      before do
        session[:user_id] = dave.id
      end

      it 'redirects to the my queue page' do
        post :update_queues, queue_items: [{id: queue_item1.id, position: 3.4}, {id: queue_item2.id, position: 2}]
        expect(response).to redirect_to my_queue_path
      end

      it 'sets the flash error message' do
        post :update_queues, queue_items: [{id: queue_item1.id, position: 3.4}, {id: queue_item2.id, position: 2}]
        expect(flash[:error]).to be_present
      end

      it 'does not change the queue items' do
        post :update_queues, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2.1}]
        expect(queue_item1.reload.position).to eq(1)
      end
    end

    context 'with queue items that do not belong to current user' do
      it 'does not change the queue items' do
        dave = Fabricate(:user)
        hal = Fabricate(:user)
        set_current_user(hal)
        video = Fabricate(:video)
        queue_item1 = Fabricate(:queue_item, user: dave, position: 1, video: video)
        queue_item2 = Fabricate(:queue_item, user: dave, position: 2, video: video)
        post :update_queues, queue_items: [{id: queue_item1.id, position: 3}, {id: queue_item2.id, position: 2}]
        expect(dave.queue_items.first.position).to eq(1)
      end
    end
  end
end
