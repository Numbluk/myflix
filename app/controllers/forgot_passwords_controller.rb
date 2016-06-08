class ForgotPasswordsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      user.generate_token
      AppMailer.delay.send_password_reset(user.id)
      redirect_to forgot_password_confirmation_path
    else
      flash[:error] = params[:email].blank? ? 'Cannot be blank' : 'Invalid email address'
      redirect_to forgot_password_path
    end
  end
end
