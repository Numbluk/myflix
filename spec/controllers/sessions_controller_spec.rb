require 'spec_helper'

describe SessionsController do
  describe 'GET new' do
    it 'redirects to the home path if current user' do
      session[:user_id] = Fabricate(:user).id
      get :new
      expect(response).to redirect_to home_path
    end
  end

  describe 'POST create' do
    context 'with valid credentials' do
      let(:dave) { Fabricate(:user) }

      before do
        post :create, email: dave.email, password: dave.password
      end

      it 'sets the sessions user id to the credentials user id' do
        expect(session[:user_id]).to eq(dave.id)
      end

      it 'redirects to the home path' do
        expect(response).to redirect_to home_path
      end

      it 'gives a notice that user is logged in' do
        expect(flash[:notice]).not_to be_blank
      end
    end

    context 'with invalid credentials' do
      let(:dave) { Fabricate(:user) }
      
      before do
        post :create, email: dave.email, password: dave.password = 'll'
      end

      it 'does not add user to session' do
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to the sign in page' do
        expect(response).to redirect_to sign_in_path
      end

      it 'sets an error message' do
        expect(flash[:error]).not_to be_blank
      end
    end
  end

  describe 'GET destroy' do
    before do
      session[:user_id] = Fabricate(:user).id
      get :destroy
    end

    it 'sets the session user id to nil' do
      expect(session[:user_id]).to be_nil
    end

    it 'gives a notice of "You are now logged out."' do
      expect(flash[:notice]).not_to be_nil
    end

    it 'redirects to the root path' do
      expect(response).to redirect_to root_path
    end
  end
end
