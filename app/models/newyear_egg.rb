class NewyearEgg < ActiveRecord::Base
  belongs_to :user

  scope :today, ->{ where(["date(created_at) = ?", Date.today]) }
  scope :not_invest, ->{where("is_invest=false")}
  scope :invest, ->{where("is_invest=true")}

  def self.create_for(user, egg)
    self.create(:user => user, :hit_level => egg, :is_invest => false)
  end

  def update_invest(invest_count)
    self.update_attributes(:invest_count => invest_count,
                           :is_invest => true)
  end
end
