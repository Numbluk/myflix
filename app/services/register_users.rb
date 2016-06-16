class RegisterUsers
  attr_reader :error_message

  def initialize(user)
    @user = user
  end

  def register(stripe_token, invitation_token)
    if @user.valid?
      response = StripeWrapper::Charge.create(amount: 1000, source: stripe_token)
      if response.successful?
        @user.save
        users_follow_each_other_if_token(invitation_token)
        AppMailer.delay.send_welcome_email(@user.id)
        @status = :success
        self
      else
        @status = :failed
        @error_message = response.error_message
        self
      end
    else
      @status = :failed
      @error_message = 'Invalid user information. Please check the problems below.'
      self
    end
  end

  def successful?
    @status == :success
  end

  private

  def users_follow_each_other_if_token(invitation_token)
    if invitation_token.present?
      invitation = Invitation.find_by(token: invitation_token)
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      Invitation.delete(invitation.id)
    end
  end
end
