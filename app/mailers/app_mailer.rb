class AppMailer < ActionMailer::Base
  def send_welcome_email(user)
    @user = user
      mail from: 'admin@myflix.com', to: @user.email, subject: 'Welcome to MyFlix!'
  end

  def send_password_reset(user)
    @user = user
    mail from: 'admin@myflix.com', to: @user.email, subject: 'Password Reset Confirmation'
  end

  def send_invitation(invitation)
    @invitation = invitation
    mail from: 'admin@myflix.com', to: @invitation.recipient_email, subject: 'You have been invited to MyFlix by a friend!'
  end
end
