class PasswordResetsController < ApplicationController
  def show
    user = User.find_by(token: params[:id])
    if user
      @token = user.token
    else
      redirect_to invalid_token_path unless user
    end
  end

  def create
    user = User.find_by(token: params[:token])
    if user
      user.password = params[:password]
      user.remove_token
      user.save
      flash[:success] = 'Password successfully changed.'
      redirect_to sign_in_path
    else
      redirect_to invalid_token_path
    end
  end
end
