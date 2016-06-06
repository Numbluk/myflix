class AppMailer < ActionMailer::Base
  def send_welcome_email(user)
    @user = user
      mail from: 'admin@myflix.com', to: @user.email, subject: 'Welcome to MyFlix!'
  end

  def send_password_reset(user)
    @user = user
    mail from: 'admin@myflix.com', to: @user.email, subject: 'Password Reset Confirmation'
  end
end
