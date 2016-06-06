require 'spec_helper'

describe ForgotPasswordsController do
  describe 'POST create' do
    after { ActionMailer::Base.deliveries.clear }

    context 'with blank input' do
      it 'redirects to the forgot password page' do
        post :create, email: ''
        expect(response).to redirect_to forgot_password_path
      end

      it 'gives an error that the email cannot be blank' do
        post :create, email: ''
        expect(flash[:error]).to eq('Cannot be blank')
      end
    end

    context 'with valid email' do
      it 'redirects to the password confirmation page' do
        Fabricate(:user, email: 'dave@dave.com')
        post :create, email: 'dave@dave.com'
        expect(response).to redirect_to forgot_password_confirmation_path
      end

      it 'sends the confirmation email' do
        Fabricate(:user, email: 'dave@dave.com')
        post :create, email: 'dave@dave.com'
        expect(ActionMailer::Base.deliveries.last.to).to eq(['dave@dave.com'])
      end

      it 'generates a token for the user' do
        user = Fabricate(:user, email: 'dave@dave.com')
        post :create, email: 'dave@dave.com'
        expect(user.reload.token).to be_present
      end
    end

    context 'with invalid email' do
      it 'redirects to the forgot password page' do
        post :create, 'some@email'
        expect(response).to redirect_to forgot_password_path
      end

      it 'gives an error message' do
        post :create, email: 'some@email'
        expect(flash[:error]).to eq('Invalid email address')
      end
    end
  end
end
