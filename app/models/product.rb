class Product < ActiveRecord::Base
  has_many :attachements
  has_many :items

  validates :title, :total_price, :desc, :numbers, :already, :remain, presence: true
  validates :total_price, :numericality => {:greater_than_or_equal_to => 1, :message => "总价必须大于等于1，请检查"}
  validates :numbers, :numericality => {:greater_than_or_equal_to => 1, :message => "库存量必须大于等于1，请检查"}
end
