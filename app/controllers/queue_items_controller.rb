class QueueItemsController < ApplicationController
  before_filter :require_user

  def index
    @queue_items = current_user.queue_items.order("position ASC")
  end

  def create
    video = Video.find(params[:video_id])
    queue_video(video)
    redirect_to my_queue_path
  end

  def update_queues
    queue_items = params[:queue_items]
    if queue_items_have_same_positions?(queue_items)
      flash[:error] = 'Items cannot have same positions.'
      redirect_to my_queue_path and return
    end

    begin
      ActiveRecord::Base.transaction do
        queue_items.each do |id, position|
            queue_item = QueueItem.find(id.to_i)
            queue_item.update!(position: position)
        end
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:error] = e.message
    end
    redirect_to my_queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id].to_i)
    QueueItem.destroy(queue_item) if queue_item.user == current_user
    redirect_to my_queue_path
  end

  private

  def queue_items_have_same_positions?(items)
    positions = items.flatten.select.each_with_index { |_, i| i.odd? }
    positions.length != positions.uniq.length ? true : false
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
