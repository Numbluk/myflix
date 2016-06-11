class UsersController < ApplicationController
  before_filter :require_user, only: [:show]

  def new
    @user = User.new
  end

  def create
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    token = params[:stripeToken]
    begin
      charge = Stripe::Charge.create(
        :amount => 1000, # amount in cents, again
        :currency => "usd",
        :source => token,
        :description => "Example charge"
      )
      @user = User.new(users_params)
      if @user.save
        users_follow_each_other_if_token(@user)
        AppMailer.delay.send_welcome_email(@user.id)
        flash[:success] = 'Account successfully created.'
        redirect_to sign_in_path
      else
        render :new
      end
    rescue Stripe::CardError => e
      flash[:error] = e.message
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
    if params[:invitation_token].present?
      invitation = Invitation.find_by(token: params[:invitation_token])
      @user.follow(invitation.inviter)
      invitation.inviter.follow(@user)
      Invitation.delete(invitation.id)
    end
  end
end
