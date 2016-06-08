class User < ActiveRecord::Base
  validates_presence_of :email, :full_name, :password
  validates_uniqueness_of :email

  has_many :reviews
  has_many :queue_items, -> { order('position') }
  has_many :reviews, -> { order('created_at DESC') }
  has_many :following_relationships, class_name: 'Relationship', foreign_key: 'follower_id'
  has_many :leading_relationships, class_name: 'Relationship', foreign_key: 'leader_id'

  has_many :invitations, foreign_key: 'inviter_id'

  has_secure_password validations: false

  def video_in_queue?(video)
    queue_items.map(&:video).include?(video)
  end

  def follows?(another_user)
    following_relationships.where(leader: another_user).any?
  end

  def follow(another_user)
    Relationship.create(follower: self, leader: another_user)
  end

  def can_follow?(another_user)
    !(self.follows?(another_user) || another_user == self)
  end

  def generate_token
    update_column(:token, SecureRandom.urlsafe_base64)
  end

  def remove_token
    update_column(:token, nil)
  end
end
