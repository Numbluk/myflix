class UsersController < ApplicationController
  before_filter :require_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(users_params)
    result = RegisterUsers.new(@user).register(params[:stripeToken], params[:invitation_token])

    if result.successful?
      flash[:success] = 'Account successfully created.'
      redirect_to sign_in_path
    else
      flash[:error] = result.error_message
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def new_with_invitation_token
    invitation = Invitation.find_by(token: params[:token])
    if invitation
      @invitation_token = invitation.token
      @user = User.new(email: invitation.recipient_email)
      render :new
    else
      redirect_to invalid_token_path
    end
  end

  private

  def users_params
    params.require(:user).permit!
  end

end
