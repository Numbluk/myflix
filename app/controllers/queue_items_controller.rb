class QueueItemsController < ApplicationController
  before_filter :require_user

  def index
    @queue_items = current_user.queue_items.order("position")
  end

  def create
    video = Video.find(params[:video_id])
    queue_video(video)
    redirect_to my_queue_path
  end

  def update_queues
    begin
      update_queue_items
      normalize_queue_item_positions
    rescue ActiveRecord::RecordInvalid
      flash[:error] = 'Invalid positions'
    end

    redirect_to my_queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id].to_i)
    QueueItem.destroy(queue_item) if queue_item.user == current_user
    normalize_queue_item_positions
    redirect_to my_queue_path
  end

  private

  def update_queue_items
    ActiveRecord::Base.transaction do
      params[:queue_items].each do |queue_item_data|
        queue_item = QueueItem.find(queue_item_data['id'])
        queue_item.update!(position: queue_item_data['position'], rating: queue_item_data['rating']) if queue_item.user == current_user
      end
    end
  end

  def normalize_queue_item_positions
    current_user.queue_items.each_with_index do |queue_item, index|
      queue_item.update_attributes(position: index + 1)
    end
  end

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
