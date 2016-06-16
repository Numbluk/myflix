require 'spec_helper'

describe UsersController do
  describe 'GET new' do
    it 'sets up @user' do
      get :new
      expect(assigns(:user)).to be_new_record
      expect(assigns(:user)).to be_instance_of(User)
    end
  end

  describe 'GET show' do
    it 'redirects if invalidated user' do
      get :show, id: 1
      expect(response).to redirect_to sign_in_path
    end

    it 'sets up a @user' do
      set_current_user
      get :show, id: current_user.id
      expect(assigns(:user)).to eq(current_user)
    end
  end

  describe 'POST create' do
    context 'successful user register' do
      it 'redirects to the sign in path' do
        register = double(:register, successful?: true)
        RegisterUsers.any_instance.should_receive(:register).and_return(register)
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'failed user register' do
      before do
        register = double(:register, successful?: false, error_message: 'This is an error')
        RegisterUsers.any_instance.should_receive(:register).and_return(register)
      end

      it 'renders the new template' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(response).to render_template :new
      end

      it 'sets the flash error message' do
        post :create, user: Fabricate.attributes_for(:user), stripeToken: '123'
        expect(flash[:error]).to be_present
      end
    end
  end

  describe 'GET new_with_invitation_token' do
    it 'renders the new template' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(response).to render_template :new
    end

    it 'redirects to the invalid token path for invalid tokens' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: '123'
      expect(response).to redirect_to invalid_token_path
    end

    it 'sets the @user with the recipient information' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:user).email).to eq(invitation.recipient_email)
    end

    it 'sets the @invitation_token' do
      invitation = Fabricate(:invitation)
      get :new_with_invitation_token, token: invitation.token
      expect(assigns(:invitation_token)).to eq(invitation.token)
    end
  end
end
