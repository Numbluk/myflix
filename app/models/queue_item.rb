class QueueItem < ActiveRecord::Base
  validates_numericality_of :position, { only_integer: true }

  belongs_to :user
  belongs_to :video

  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video

  def self.save_and_update_positions(queue_ids_with_positions)
    begin
      ActiveRecord::Base.transaction do
        queue_ids_with_positions.each do |id, position|
          queue_item = QueueItem.find(id.to_i)
          queue_item.update!(position: position)
        end
      end
      nil
    rescue ActiveRecord::RecordInvalid => e
      e.message
    end
  end

  def position_cannot_be_less_than_one
    if !position.nil? && position < 1
      errors.add(:position, "can't be less than 1")
    end
  end

  def position_cannot_be_greater_than_queue_items_count
    if (QueueItem.exists?(id) && position && position > QueueItem.count) || (!QueueItem.exists?(id) && position && position > QueueItem.count + 1)
      errors.add(:position, "can't be greater than number of queue items")
    end
  end

  def rating
    review = user.reviews.find_by(video: video)
    review.rating if review
  end

  def category_name
    category.name
  end
end
