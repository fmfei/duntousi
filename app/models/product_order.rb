class ProductOrder < ActiveRecord::Base
  belongs_to :user
  belongs_to :item

  scope :hit_order, ->{where("is_hit = true")}

  def self.create_for(user, item_id, amount, numbers)
    order = self.create(user: user, item_id: item_id, amount: amount, numbers: numbers)
    CashFlow.create_yiyuangou user, order, amount
    order
  end
end
