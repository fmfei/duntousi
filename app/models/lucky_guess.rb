class LuckyGuess < ActiveRecord::Base
	belongs_to :user

	scope :before_today, ->{ where(["date(created_at) <= ?", Date.today-1]) }
  scope :today, ->{ where(["date(created_at) = ?", Date.today]) }
	scope :win, ->{ where(["result = ?", "win"]) }
	scope :null, ->{ where("result is null") }

	def self.create_for user_id, guess
		self.create(:user_id => user_id, :guess => guess)

	end

	def win_or_not guess
		if guess == self.guess
			CashFlow.prize self.user, 30
			self.result = "win"
		else
			self.result = "not_win"
		end
		self.save
	end

	def prize
		return "30元现金" if self.result == "win"
	end
end
