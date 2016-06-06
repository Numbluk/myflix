require 'spec_helper'

describe RelationshipsController do
  describe 'GET index' do
    it 'sets up the @relationships associated with the current user' do
      dave = Fabricate(:user)
      set_current_user(dave)
      hal = Fabricate(:user)
      relationship = Fabricate(:relationship, leader: hal, follower: dave)
      get :index
      expect(assigns(:relationships)).to eq([relationship])
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { get :index }
    end
  end

  describe 'POST create' do
    it_behaves_like 'require_sign_in' do
      let(:action) { post :create }
    end

    it 'creates a relationship where the current user follows the leader' do
      dave = Fabricate(:user)
      set_current_user(dave)
      hal = Fabricate(:user)
      post :create, leader_id: hal.id
      expect(dave.following_relationships.first.leader).to eq(hal)
    end

    it 'redirects to the people page' do
      dave = Fabricate(:user)
      set_current_user(dave)
      hal = Fabricate(:user)
      post :create, leader_id: hal.id
      expect(response).to redirect_to people_path
    end

    it 'does not allow a user to follow a leader more than once' do
      dave = Fabricate(:user)
      set_current_user(dave)
      hal = Fabricate(:user)
      Fabricate(:relationship, leader: hal, follower: dave)
      post :create, leader_id: hal.id
      expect(Relationship.count).to eq(1)
    end

    it 'does not allow a user to follow themselves' do
      dave = Fabricate(:user)
      set_current_user(dave)
      post :create, leader_id: dave.id
      expect(Relationship.count).to eq(0)
    end
  end

  describe 'DELETE destroy' do
    it_behaves_like 'require_sign_in' do
      let(:action) { delete :destroy, id: 1 }
    end

    let(:dave) { Fabricate(:user) }
    let(:hal) { Fabricate(:user) }

    before { set_current_user(dave) }

    it 'deletes the relationship associated with the current user' do
      relationship = Fabricate(:relationship, leader: hal, follower: dave)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(0)
    end

    it 'redirects to the people path' do
      relationship = Fabricate(:relationship, leader: hal, follower: dave)
      delete :destroy, id: relationship.id
      expect(response).to redirect_to people_path
    end

    it 'a user can only delete relationships if they are a follower' do
      relationship = Fabricate(:relationship, leader: dave, follower: hal)
      delete :destroy, id: relationship.id
      expect(Relationship.count).to eq(1)
    end
  end
end
