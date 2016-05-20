require 'spec_helper'

describe UsersController do
  describe 'GET new' do
    it 'sets up @user' do
      get :new
      expect(assigns(:user)).to be_new_record
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe 'POST create' do

    context 'with valid input' do
      before do
        post :create, user: Fabricate.attributes_for(:user)
      end

      it 'creates the @user' do
        expect(User.count).to eq(1)
      end

      it 'redirects to the sign in path' do
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'with invalid input' do
      before do
        post :create, user: { full_name: '', email: '', password: 'password123'}
      end

      it 'sets up @user with input' do
        user = { full_name: 'Dave Thomas', email: 'Dave@example.com', password: 'password123'}
        post :create, user: user
        expect(assigns(:user).full_name).to eq(user[:full_name])
      end

      it 'does not create the @user' do
        expect(User.count).to eq(0)
      end

      it 'renders to the :new template' do
        expect(response).to render_template :new
      end
    end
  end
end
