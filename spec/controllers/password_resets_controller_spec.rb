require 'spec_helper'

describe PasswordResetsController do
  describe 'GET show' do
    it 'render show template if token is valid' do
      Fabricate(:user, token: '12345')
      get :show, id: '12345'
      expect(response).to render_template :show
    end

    it 'sets a token' do
      Fabricate(:user, token: '12345')
      get :show, id: '12345'
      expect(assigns(:token)).to eq('12345')
    end

    it 'redirects to invalid token page if token is invalid' do
      get :show, id: '12345'
      expect(response).to redirect_to invalid_token_path
    end
  end

  describe 'POST create' do
    context 'with a valid token' do
      it 'updates the user password' do
        dave = Fabricate(:user, token: '12345', password: 'old')
        post :create, password: 'new', token: '12345'
        expect(dave.reload.authenticate('new')).to be_true
      end

      it 'redirects to the sign in page' do
        dave = Fabricate(:user, token: '12345', password: 'old')
        post :create, password: 'new', token: '12345'
        expect(response).to redirect_to sign_in_path
      end

      it 'sets the success mesage' do
        dave = Fabricate(:user, token: '12345', password: 'old')
        post :create, password: 'new', token: '12345'
        expect(flash[:success]).to be_present
      end

      it 'removes the token' do
        dave = Fabricate(:user, token: '12345', password: 'old')
        post :create, password: 'new', token: '12345'
        expect(dave.reload.token).to be_nil
      end
    end

    context 'with invalid token' do
      it 'redirects to the expired token path' do
        post :create, password: 'new', token: '12345'
        expect(response).to redirect_to invalid_token_path
      end
    end
  end
end
