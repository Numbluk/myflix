class Video < ActiveRecord::Base
  belongs_to :category, -> { order(:created_at) }
  has_many :reviews, -> { order('created_at DESC') }
  validates_presence_of :title, :description

  def self.search_by_title(keywords)
    return [] if keywords.blank?
    Video.where('lower(title) LIKE ?', "%#{keywords}%".downcase).order('created_at DESC')
  end
end
