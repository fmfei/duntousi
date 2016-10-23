class HuodongComment < ActiveRecord::Base
	belongs_to :user

	scope :result1, ->{where(["result = ?", 1])}
	scope :result0, ->{where(["result = ?", 0])}
  scope :today, ->{where(["data(create_at = >)", Data.today])}

	def self.create_for(user, comment, type)
		self.create(:user => user, :comment => comment, :result => type)
	end

end
