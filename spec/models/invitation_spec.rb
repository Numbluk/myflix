require 'spec_helper'

describe Invitation do
  it { should belong_to(:inviter).class_name('User') }
  it { should validate_presence_of(:message) }
  it { should validate_presence_of(:recipient_email) }
  it { should validate_presence_of(:recipient_name) }

  describe '#generate_token' do
    it 'generates a token before creation' do
      invitation = Fabricate(:invitation, token: '')
      expect(invitation.token).to be_present
    end
  end
end
