class VideosController < ApplicationController
  before_filter :require_user

  def index
    @categories = Category.all
  end

  def show
    @video = Video.find(params[:id]).decorate
    @reviews = @video.reviews
  end

  def search
    @search_text = params[:search_text]
    @videos = Video.search_by_title(@search_text)
  end
end
