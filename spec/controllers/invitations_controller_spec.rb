require 'spec_helper'

describe InvitationsController do
  describe 'GET new' do
    it 'sets the @invitation' do
      set_current_user
      get :new
      expect(assigns(:invitation)).to be_a_new(Invitation)
    end

    it_behaves_like 'require_sign_in' do
      let(:action) { get :new }
    end
  end

  describe 'POST create' do
    context 'with valid input' do
      after { ActionMailer::Base.deliveries.clear }

      it 'redirects to the invite page' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: 'hal@hal.com', recipient_name: 'hal', message: 'join me, hal' }
        expect(response).to redirect_to invite_path
      end

      it 'creates an invitation' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: 'hal@hal.com', recipient_name: 'hal', message: 'join me, hal' }
        expect(Invitation.count).to eq(1)
      end

      it 'sends an email to the recipient' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: 'hal@hal.com', recipient_name: 'hal', message: 'join me, hal' }
        expect(ActionMailer::Base.deliveries.last.to).to eq(['hal@hal.com'])
      end

      it 'sets a flash success message' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: 'hal@hal.com', recipient_name: 'hal', message: 'join me, hal' }
        expect(flash[:success]).to be_present
      end
    end

    context 'with invalid input' do
      it 'renders the new template' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: '', recipient_name: 'hal', message: 'join me, hal' }
        expect(response).to render_template :new
      end

      it 'sets up an @invitation' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: '', recipient_name: 'hal', message: 'join me, hal' }
        expect(assigns(:invitation)).to be_present
      end

      it 'does not create an invitation' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: '', recipient_name: 'hal', message: 'join me, hal' }
        expect(Invitation.count).to eq(0)
      end

      it 'does not send out an email' do
        dave = Fabricate(:user)
        set_current_user(dave)
        post :create, invitation: { recipient_email: '', recipient_name: 'hal', message: 'join me, hal' }
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
