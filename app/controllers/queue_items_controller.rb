class QueueItemsController < ApplicationController
  before_filter :require_user

  def index
    @queue_items = current_user.queue_items
  end

  def create
    video = Video.find(params[:video_id])
    queue_video(video)
    redirect_to my_queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id].to_i)
    QueueItem.destroy(queue_item) if queue_item.user == current_user
    redirect_to my_queue_path
  end

  private

  def queue_video(video)
    QueueItem.create(video: video, user: current_user, position: current_queue_item_position) unless queued_video_for_current_user?(video)
  end

  def current_queue_item_position
    current_user.queue_items.count + 1
  end

  def queued_video_for_current_user?(video)
    current_user.queue_items.map(&:video).include?(video)
  end
end
