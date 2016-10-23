class LuckyCode < ActiveRecord::Base
	belongs_to :user

	scope :not, ->{where('status is null')}
	scope :wait, ->{ where("status = 'wait'")}
	scope :today, ->{ where(["date(created_at) = ?", Date.today])}
	scope :win, ->{where("status = 'win'")}
	scope :not_win, ->{where("status = 'not_win'")}
	scope :not_null, ->{where('one is not null')}
	scope :null, ->{where('one is null')}

	def self.create_for user_id
		self.create(:user_id => user_id)
	end

	def win_or_not w_number
		win_arr = w_number.split('')
		self_arr = [self.one.to_s, self.two.to_s, self.three.to_s, self.four.to_s, self.five.to_s, self.six.to_s]
		
		length = 0
		win_arr.each_with_index do |n, i|
			length += 1 if n == self_arr[i]
		end

		self.hit_number = length
		self.win_number = w_number
		case self.hit_number
		when 2
			CashFlow.prize self.user, 68
			self.status = 'win'
		when 3
			CashFlow.prize self.user, 368
			self.status = 'win'
		when 4
			CashFlow.prize self.user, 968
			self.status = 'win'
		when 5
			self.status = 'win'
		when 6
			self.status = 'win'
		else
			self.status = 'not_win'
		end
		self.save
	end

	def prize
		case self.hit_number
		when 2
			'68元现金'
		when 3
			'368元现金'
		when 4
			'968元现金'
		when 5
			'泰国5日游或iPhone6S或三星6S'
		when 6
			'86868现金'
		end
	end

	def consolation
		CashFlow.prize self.user, 20
	end

end
