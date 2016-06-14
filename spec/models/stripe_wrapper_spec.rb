require 'spec_helper'

describe StripeWrapper::Charge do
  describe '.create' do
    before { StripeWrapper.set_api_key }

    let(:token) {
      Stripe::Token.create(
        :card => {
          :number => cc,
          :exp_month => 6,
          :exp_year => 2018,
          :cvc => "314"
        },
      )
    }

    context 'with valid input' do
      let(:cc) { '4242424242424242' }
      it 'charges the cc', :vcr do
        response = StripeWrapper::Charge.create(amount: 1000, source: token)
        expect(response.successful?).to be_true
      end
    end

    context 'with invalid input', :vcr do
      let(:cc) { '4000000000000002'}
      let(:response) { StripeWrapper::Charge.create(amount: 1000, source: token) }

      it 'does not charge the cc', :vcr do
        expect(response).not_to be_successful
      end

      it 'sets an error message' do
        expect(response.error_message).to eq('Your card was declined.')
      end
    end
  end
end
