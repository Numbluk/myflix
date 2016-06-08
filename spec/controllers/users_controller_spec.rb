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
    context 'with valid input' do
      it 'creates the @user' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(User.count).to eq(1)
      end

      it 'redirects to the sign in path' do
        post :create, user: Fabricate.attributes_for(:user)
        expect(response).to redirect_to sign_in_path
      end

      it 'makes the @user follow the inviter' do
        dave = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: dave)
        post :create, user: Fabricate.attributes_for(:user), invitation_token: invitation.token
        expect(assigns(:user).follows?(dave)).to eq(true)
      end

      it 'makes the inviter follow the @user' do
        dave = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: dave)
        post :create, user: Fabricate.attributes_for(:user), invitation_token: invitation.token
        expect(dave.follows?(assigns(:user))).to eq(true)
      end

      it 'deletes the invitation' do
        dave = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: dave)
        post :create, user: Fabricate.attributes_for(:user), invitation_token: invitation.token
        expect(Invitation.count).to eq(0)
      end
    end

    context 'email sending' do
      let(:dave) { Fabricate.attributes_for(:user) }
      after { ActionMailer::Base.deliveries.clear }

      it 'sends out an email' do
        post :create, user: dave
        expect(ActionMailer::Base.deliveries).to be_present
      end

      it 'sends the email to the correct user' do
        post :create, user: dave
        msg = ActionMailer::Base.deliveries.last
        expect(msg.to).to eq([dave[:email]])
      end

      it 'has the correct content' do
        post :create, user: dave
        msg = ActionMailer::Base.deliveries.last
        expect(msg.body).to include("Welcome to MyFlix, #{dave[:full_name]}!")
      end

      it 'does not send out the email for invalid input' do
        post :create, user: Fabricate.attributes_for(:user, email: '')
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end

    context 'with invalid input' do
      before do
        post :create, user: { full_name: '', email: '', password: 'password123' }
      end

      it 'sets up @user with input' do
        post :create, user: Fabricate.attributes_for(:user, full_name: 'Dave Thomas')
        expect(assigns(:user).full_name).to eq('Dave Thomas')
      end

      it 'does not create the @user' do
        expect(User.count).to eq(0)
      end

      it 'renders to the :new template' do
        expect(response).to render_template :new
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
