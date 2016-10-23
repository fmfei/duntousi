class Banner < ActiveRecord::Base
#  attr_accessible :inner_html, :status, :title, :pic, :weight

  default_scope {order("weight")}
  scope :display, -> {where(status: true)}
  scope :for_pc, -> {where(for_app: false)}
  scope :for_app, -> {where(for_app: true)}


  mount_uploader :pic, BannerPicUploader
  validates :title, presence: true
  validates :url, presence: true
  validates :pic, presence: true

  after_create :update_weight

  def update_weight
    self.update_attribute(:weight, (Banner.first.weight - 1))
  end

end
