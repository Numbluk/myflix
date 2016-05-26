require 'spec_helper.rb'

describe QueueItemsController do
  describe 'GET index' do
    it 'sets @queue_items to the queue items of the user that is logged in' do
      user = Fabricate(:user)
      session[:user_id] = user.id
      queue_item1 = Fabricate(:queue_item, user: user, position: 1)
      queue_item2 = Fabricate(:queue_item, user: user, position: 2)
      get :index
      expect(assigns(:queue_items)).to match_array([queue_item1, queue_item2])
    end

    it 'redirects users who are not logged in' do
      session[:user_id] = nil
      get :index
      expect(response).to redirect_to sign_in_path
    end

    it 'orders the queue items in ascending order by position' do
      user = Fabricate(:user)
      session[:user_id] = user.id
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

  describe 'PATCH update_queues' do
    context 'for updating positions' do
      context 'for authenticated users' do
        it 'redirects to my queue path' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          patch :update_queues, queue_ids_with_positions: {}
          expect(response).to redirect_to my_queue_path
        end

        it 'changes the position of two queue items' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 2, queue_item2.id.to_s => 1 }
          expect(QueueItem.first.position).to eq(2)
        end

        it 'does not change the position of several list items if two positions are same' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 1,  queue_item2.id.to_s => 1 }
          expect(queue_item2.position).to eq(2)
        end

        it 'returns an error notice if two positions are the same' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 1,  queue_item2.id.to_s => 1 }
          expect(flash[:error]).not_to be_empty
        end

        it 'does not change position if a position is less than 1' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 0,  queue_item2.id.to_s => 2 }
          expect(QueueItem.first.position).to eq(1)
          expect(QueueItem.second.position).to eq(2)
        end

        it 'does not change the position if something other than an integer is submitted' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 0,  queue_item2.id.to_s => 'l' }
          expect(QueueItem.first.position).to eq(1)
          expect(QueueItem.second.position).to eq(2)
        end

        it 'if position is less than 1 or something other than integer then error message exists' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 0,  queue_item2.id.to_s => 'l' }
          expect(flash[:error]).not_to be_empty
        end

        it 'does not change position if position is great than number of queue items' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 1,  queue_item2.id.to_s => 1000 }
          expect(QueueItem.first.position).to eq(1)
          expect(QueueItem.second.position).to eq(2)
        end

        it 'if position is greater than number of queue items then error message exists' do
          user = Fabricate(:user)
          session[:user_id] = user.id
          queue_item1 = Fabricate(:queue_item, id: 1, position: 1)
          queue_item2 = Fabricate(:queue_item, id: 2, position: 2)
          patch :update_queues, queue_ids_with_positions: { queue_item1.id.to_s => 1,  queue_item2.id.to_s => 1000 }
          expect(flash[:error]).not_to be_empty
        end
      end

      context 'for unauthenticated users' do
        it 'redirects to sign in path' do
          session[:user_id] = nil
          patch :update_queues
          expect(response).to redirect_to sign_in_path
        end
      end
    end

    context 'for updating ratings' do
      context 'for authenticated users' do
        context 'for reviews that already exist' do
          it 'changes the rating for the associated user ' do
            user = Fabricate(:user)
            session[:user_id] = user.id
            video = Fabricate(:video)
            review = Fabricate(:review, rating: 5, video: video, user: user)
            queue_item = Fabricate(:queue_item, id: 1, position: 1, user: user, video: video)
            patch :update_queues, queue_ids_with_positions: { queue_item.id.to_s => queue_item.id }, queue_ids_with_ratings: { queue_item.id.to_s => 1 }
            expect(QueueItem.first.user.reviews.first.rating).to eq(1)
          end

          it 'changes the rating for the associated video' do
            user = Fabricate(:user)
            session[:user_id] = user.id
            video = Fabricate(:video)
            review = Fabricate(:review, rating: 5, video: video, user: user)
            queue_item = Fabricate(:queue_item, id: 1, position: 1, user: user, video: video)
            patch :update_queues, queue_ids_with_positions: { queue_item.id.to_s => queue_item.id }, queue_ids_with_ratings: { queue_item.id.to_s => 1 }
            expect(QueueItem.first.video.reviews.first.rating).to eq(1)
          end
        end

        context 'for reviews that do not exist' do
          it 'creates a new review' do
            user = Fabricate(:user)
            session[:user_id] = user.id
            video = Fabricate(:video)
            queue_item = Fabricate(:queue_item, id: 1, position: 1, user: user, video: video)
            patch :update_queues, queue_ids_with_positions: { queue_item.id.to_s => queue_item.id }, queue_ids_with_ratings: { queue_item.id.to_s => 1 }
            expect(Review.count).to eq(1)
          end

          it 'saves the new rating as the rating for new review' do
            user = Fabricate(:user)
            session[:user_id] = user.id
            video = Fabricate(:video)
            queue_item = Fabricate(:queue_item, id: 1, position: 1, user: user, video: video)
            patch :update_queues, queue_ids_with_positions: { queue_item.id.to_s => queue_item.id }, queue_ids_with_ratings: { queue_item.id.to_s => 1 }
            expect(Review.first.rating).to eq(1)
          end

          it 'saves the new rating for the associated user' do
            user = Fabricate(:user)
            session[:user_id] = user.id
            video = Fabricate(:video)
            queue_item = Fabricate(:queue_item, id: 1, position: 1, user: user, video: video)
            patch :update_queues, queue_ids_with_positions: { queue_item.id.to_s => queue_item.id }, queue_ids_with_ratings: { queue_item.id.to_s => 1 }
            expect(Review.first.user).to eq(user)
          end

          it 'saves the new rating for the associated video' do
            user = Fabricate(:user)
            session[:user_id] = user.id
            video = Fabricate(:video)
            queue_item = Fabricate(:queue_item, id: 1, position: 1, user: user, video: video)
            patch :update_queues, queue_ids_with_positions: { queue_item.id.to_s => queue_item.id }, queue_ids_with_ratings: { queue_item.id.to_s => 1 }
            expect(Review.first.video).to eq(video)
          end
        end
      end

      context 'for unauthenticated users' do
        it 'redirects to sign in path' do
          session[:user_id] = nil
          patch :update_queues
          expect(response).to redirect_to sign_in_path
        end
      end
    end
  end
end
