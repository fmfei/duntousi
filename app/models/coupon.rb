class Coupon < ActiveRecord::Base
  belongs_to :user
  scope :used, -> {where(status: 'used')}
  scope :unused, -> {where(status: 'unused')}

  def self.create_for user_id, amount, count
    count.to_i.times do
      self.create(user_id: user_id.to_i,
                  amount: amount.to_f,
                  status: 'unused')
    end
  end

end
