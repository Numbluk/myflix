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
    update_reviews(params[:queue_ids_with_ratings]) if params[:queue_ids_with_ratings]
    queue_ids_with_positions = params[:queue_ids_with_positions]
    if queue_items_have_same_positions?(queue_ids_with_positions)
      flash[:error] = 'Items cannot have same positions.'
    else
      flash[:error] = QueueItem.save_and_update_positions(queue_ids_with_positions)
    end

    redirect_to my_queue_path
  end

  def destroy
    queue_item = QueueItem.find(params[:id].to_i)
    QueueItem.destroy(queue_item) if queue_item.user == current_user
    redirect_to my_queue_path
  end

  private

  def update_reviews(queue_ids_with_ratings)
    queue_ids_with_ratings.each do |id, rating|
      queue_item = QueueItem.find(id)
      review = Review.find_by(user: current_user, video: queue_item.video)
      if review
        review.update(rating: rating.to_i)
      else
        review = Review.new(user: current_user, video: queue_item.video, rating: rating)
        review.save(validate: false)
      end
    end
  end

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
