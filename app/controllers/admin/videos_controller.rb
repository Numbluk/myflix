class Admin::VideosController < ApplicationController
  before_filter :require_user
  before_filter :require_admin

  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      flash[:success] = "'#{@video.title}' successfully created!"
      redirect_to new_admin_video_path
    else
      flash[:error] = 'Invalid input'
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :category_id, :large_cover, :small_cover, :video_url)
  end

  def require_admin
    if !current_user.admin?
      flash[:error] = 'You do not have those privileges.'
      redirect_to home_path unless current_user.admin?
    end
  end
end
