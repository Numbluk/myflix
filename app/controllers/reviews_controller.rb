class ReviewsController < ApplicationController
  before_filter :require_user

  def create
    @video = Video.find(params[:video_id])
    binding.pry
    @review = Review.new(reviews_params.merge!(user: current_user, video: @video))
    if @review.save
      redirect_to video_path(@video), notice: 'Review successfully created.'
    else
      @reviews = @video.reviews.reload
      render 'videos/show'
    end
  end

  private

  def reviews_params
    params.require(:review).permit!
  end
end
