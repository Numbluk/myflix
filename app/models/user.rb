class User < ActiveRecord::Base
  validates_presence_of :email, :password, :full_name
  validates_uniqueness_of :email

  has_many :reviews
  has_many :queue_items, -> { order('position') }

  has_secure_password validations: false

  def video_in_queue?(video)
    queue_items.map(&:video).include?(video)
  end
end
