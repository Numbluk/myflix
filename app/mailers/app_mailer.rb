class AppMailer < ActionMailer::Base
  default from: 'myflix@example.com'

  def send_welcome_email(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: 'Welcome to MyFlix!'
  end

  def send_password_reset(user_id)
    @user = User.find(user_id)
    mail to: @user.email, subject: 'Password Reset Confirmation'
  end

  def send_invitation(invitation_id)
    @invitation = Invitation.find(invitation_id)
    mail to: @invitation.recipient_email, subject: 'You have been invited to MyFlix by a friend!'
  end
end
