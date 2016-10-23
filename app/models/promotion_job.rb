class PromotionJob
	@queue = :high

  def self.perform(job_name, options)
  	self.send(job_name, options)
  end

	def self.prize loan_id
		loan = Loan.find loan_id
		bids = loan.bids
		SystemConfig.transaction do
			# 邀请奖励
			if SystemConfig.promotion_status.value == 'on'

				lenders = User.find bids.map(&:user_id).uniq

				if SystemConfig.promotion_type.value == 'fixed' && SystemConfig.promotion_amount.value.to_f > 0

					lenders.select{|lender| lender.from_user_id.present?}.each do |lender|

						invest_amount = bids.select{|bid| bid.user_id == lender.id}.sum(&:invest_amount)

						if SystemConfig.promotion_threshold.value.to_f <= invest_amount
							prize = SystemConfig.promotion_amount.value.to_f
							CashFlow.invite_prize lender.from_user, prize, lender.id, loan
						end

					end

				elsif SystemConfig.promotion_type.value == 'ratio' && SystemConfig.promotion_ratio.value.to_f > 0

					lenders.select{|lender| lender.from_user_id.present?}.each do |lender|

						invest_amount = bids.select{|bid| bid.user_id == lender.id}.sum(&:invest_amount)
						if SystemConfig.promotion_threshold.value.to_f <= invest_amount
							prize = SystemConfig.promotion_ratio.value.to_f * invest_amount / 100
							CashFlow.invite_prize lender.from_user, prize, lender.id, loan
						end

					end

				end
					
			end

			# 首投奖
			if SystemConfig.prize_first_status.value == 'on' && SystemConfig.prize_first_amount.value.to_f > 0

				first_manual_bid = bids.manual.first

				if first_manual_bid.present?
					if first_manual_bid.invest_amount >= SystemConfig.prize_first_threshold.value.to_f
						CashFlow.bid_prize first_manual_bid.user, SystemConfig.prize_first_amount.value.to_f, first_manual_bid
					end
				end

			end

			# 单标冠军奖
			if SystemConfig.prize_max_status.value == 'on' && SystemConfig.prize_max_amount.value.to_f > 0

				manual_bids = bids.manual
				if manual_bids.present?
					max_user = manual_bids.group_by{|b|b.user_id}.max_by{|a| a[1].sum{|bids|bids.invest_amount}}[1].first.user
					CashFlow.bid_prize max_user, SystemConfig.prize_max_amount.value.to_f, loan, 'prize_max'
				end

			end

			#满标奖
			if SystemConfig.prize_last_status.value == 'on' && SystemConfig.prize_last_amount.value.to_f > 0 && loan.bids.last.auto_invest == false
				
				CashFlow.bid_prize loan.bids.last.user, SystemConfig.prize_last_amount.value.to_f, loan.bids.last, 'prize_last'
			end

		end # end of transaction
	end

	# 注册奖励
	def self.prize_register user_id
		user = User.find user_id
		if user.present?
			CashFlow.bid_prize user, SystemConfig.prize_register_amount.value.to_f, user, 'prize_register'
		end
	end

	def self.lucky_code option 
		invest_amount = option['invest_amount'] 
		load_month = option['loan_month'] 
		user_id = option['user_id']
    if invest_amount.to_f >= 5000
	    if load_month == 1
	      (invest_amount.to_i / 5000).to_i.times do
	        LuckyCode.create_for(user_id)
	      end
	    elsif load_month >= 3
	      ((invest_amount.to_i / 5000).to_i*2).times do
	        LuckyCode.create_for(user_id)
	      end
	    end
	  end
	end

	def self.newyear_egg option
		invest_amount = option['invest_amount']
		current_user = User.find option['user_id']
		egg_recorde = NewyearEgg.where("user_id = ?", current_user.id).today.not_invest
		# egg_recorde = current_user.newyear_eggs.today.not_invest #获取当日砸蛋记录中还没投资过的记录
    if egg_recorde.present?
      #如果投资的金额不小于砸蛋对应的最低金额，则发红包
      egg_recorde.order("hit_level desc").each do |recorde|
        hit_level = recorde.hit_level
        if (invest_amount.to_f >= 200000 && hit_level <= 1868) || (invest_amount.to_f >= 120000 && hit_level <= 868) || (invest_amount.to_f >= 60000 && hit_level <= 568) || (invest_amount.to_f >= 35000 && hit_level <= 268) || (invest_amount.to_f >= 10000 && hit_level <= 68)
          recorde.update_invest(invest_amount)
          CashFlow.prize current_user, hit_level
          break
        end
      end
      
    end
	end

end