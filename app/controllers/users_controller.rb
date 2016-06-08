class UsersController < ApplicationController
  before_filter :require_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    @user = User.new(users_params)
    if @user.save
      users_follow_each_other_if_token(@user)
      AppMailer.delay.send_welcome_email(@user.id)
      redirect_to sign_in_path
    else
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

  def users_follow_each_other_if_token(user)
    if params[:invitation_token]
      invitation = Invitation.find_by(token: params[:invitation_token])
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      Invitation.delete(invitation.id)
    end
  end
end
