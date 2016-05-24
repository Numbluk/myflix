class QueueItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :video

  delegate :category, to: :video
  delegate :title, to: :video, prefix: :video

  def rating
    review = user.reviews.find_by(video: self.video)
    review.rating if review
  end

  def category_name
    category.name
  end
end
