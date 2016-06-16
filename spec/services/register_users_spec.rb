require 'spec_helper'

describe RegisterUsers do
  describe '#register' do
    context 'with valid input' do
      before do
        charge = double(:charge, successful?: true)
        StripeWrapper::Charge.should_receive(:create).and_return(charge)
      end

      after { ActionMailer::Base.deliveries.clear }

      it 'creates the @user' do
        RegisterUsers.new(Fabricate.build(:user)).register('stripe_token', nil)
        expect(User.count).to eq(1)
      end

      it 'makes the @user follow the inviter' do
        dave = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: dave)
        RegisterUsers.new(Fabricate.build(:user, email: 'hal@hal.com')).register('stripe_token', invitation.token)
        hal = User.find_by(email: 'hal@hal.com')
        expect(hal.follows?(dave)).to eq(true)
      end

      it 'makes the inviter follow the @user' do
        dave = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: dave)
        RegisterUsers.new(Fabricate.build(:user, email: 'hal@hal.com')).register('stripe_token', invitation.token)
        hal = User.find_by(email: 'hal@hal.com')
        expect(dave.follows?(hal)).to eq(true)
      end

      it 'deletes the invitation' do
        dave = Fabricate(:user)
        invitation = Fabricate(:invitation, inviter: dave)
        RegisterUsers.new(Fabricate.build(:user, email: 'hal@hal.com')).register('stripe_token', invitation.token)
        expect(Invitation.count).to eq(0)
      end

      it 'sends the email to the correct user' do
        dave = Fabricate.build(:user)
        RegisterUsers.new(dave).register('stripe_token', nil)
        msg = ActionMailer::Base.deliveries.last
        expect(msg.to).to eq([dave[:email]])
      end

      it 'has the correct content' do
        dave = Fabricate.build(:user)
        RegisterUsers.new(dave).register('stripe_token', nil)
        msg = ActionMailer::Base.deliveries.last
        expect(msg.body).to include("Welcome to MyFlix, #{dave[:full_name]}!")
      end
    end

    context 'with valid user information and invalid cc' do
      before do
        charge = double(:charge, successful?: false, error_message: 'CC Error')
        StripeWrapper::Charge.stub(:create).and_return(charge)
      end

      it 'does not create a new user record' do
        dave = Fabricate.build(:user)
        RegisterUsers.new(dave).register('stripe_token', nil)
        expect(User.count).to eq(0)
      end
    end

    context 'with invalid personal information' do
      let(:dave) { Fabricate.build(:user, email: '') }

      before do
        charge = double(:charge, successful?: true)
        StripeWrapper::Charge.stub(:create).and_return(charge)
        RegisterUsers.new(dave).register('stripe_token', nil)
      end

      after { ActionMailer::Base.deliveries.clear }

      it 'does not create the @user' do
        expect(User.count).to eq(0)
      end

      it 'does not charge the cc' do
        expect(StripeWrapper::Charge).not_to receive(:create)
      end

      it 'does not send out the email for invalid input' do
        expect(ActionMailer::Base.deliveries).to be_empty
      end
    end
  end
end
