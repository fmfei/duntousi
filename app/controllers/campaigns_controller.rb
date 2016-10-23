# encoding: utf-8
class CampaignsController < ApplicationController
	# 转盘活动
	def circle
		render layout: false
	end

	# 上线活动
	def online
		# @users = UserCash.includes(:user).where('user_id > 0 and invest_total is not null and user_id not in (143, 131, 153, 211, 155, 325, 155, 406, 141, 260, 6978, 139)').reorder('user_cashes.invest_total desc').limit(10).select{|c| c.user.present? && c.user.mobile.present? }
		cashes = UserCash.includes(:user).where('user_id > 0 and invest_total is not null').reorder('user_cashes.invest_total desc').limit(30).select{|c| c.user.present? && c.user.mobile.present? }
		@users = cashes.sort_by!{|cash| (cash.invest_total - cash.user.bids.includes(:loan).where("char_length(pass) > 0").sum(:invest_amount)) }.reverse[0, 10]
		render layout: false
	end

	def circle_prize
		prize = current_user.circle_records.not_actived.order('id asc').first
		if prize.present?
			prize.update_attribute(:actived_at, Time.now)
			render :text => prize.angle
		else
			render :text => '-1'
		end
	end

	def august
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2015, 8, 1), DateTime.new(2015, 9, 1)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..9]

	end

	def anniversary
	end

	def september
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2015, 9, 1), DateTime.new(2015, 10, 1)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..9]
	end

	def anti_japanese
		@records = EggRecord.last(7)
	end

	def anti_api
		if Date.today < Date.new(2015, 9, 6)
			render text: '活动9月6日开始'
		else
			if current_user && params[:egg].present?
				res = EggRecord.create_for(current_user, params[:egg])
				render text: res
			else
				render text: '请注册、投资后，刷新页面参与活动'
			end
		end
	end

	def zhongqiu

	end

	def zhongqiu_start
		if current_user && params[:level]
			res = ZhongqiuRecord.create_for(current_user, params[:level])
			render :text => res
		else
			render :text => '请登录后操作'
		end
	end

	def zhongqiu_end
		if current_user && params[:level]
			res = ZhongqiuRecord.finish_for(current_user, params[:level])
			render :text => res
		else
			render :text => '请登录后操作'
		end
	end

	def zhongqiu_fail
		if current_user && params[:level]
			res = ZhongqiuRecord.fail_for(current_user, params[:level])
			render :text => res
		else
			render :text => '请登录后操作'
		end
	end

	def anniversary_report

	end

	def october
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2015, 10, 1), DateTime.new(2015, 11, 1)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..9]
	end

	def november
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2015, 11, 1), DateTime.new(2015, 12, 1)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..9]
	end

	def guanggun
	end

	def december
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2015, 12, 1), DateTime.new(2016, 1, 1)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..9]
	end

	def hd20160101
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2016, 1, 1), DateTime.new(2016, 2, 1)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..9]
	end

	def december_app
	end

	def apponline
		render layout: false
	end

	def lucky_code

	end

	def update_lucky_code
		if current_user.present?
			#lucky_code = LuckCode.find(params[:id])
			#lucky_code.update_attributes(paramsxxxxx)
			if params[:one].nil? || params[:two].nil? || params[:three].nil? || params[:four].nil? || params[:five].nil? || params[:six].nil?
				flash[:success] = "请填写完成后再提交"
				redirect_to :action => "annual_celebration"
				return ;
			end
			#lucky_code = LuckyCode.today.where("user_id = ?", current_user.id).where('status is null').first
			lucky_code = current_user.lucky_codes.today.not.first
			if lucky_code.present?
				kj_status = LuckyCode.today.win | LuckyCode.today.not_win
				if kj_status.present?
					flash[:success] = "今天已开奖，您明天再来试试吧。"
				else
					lucky_code.update_attributes(one: params[:one], two: params[:two], three: params[:three], four: params[:four], five: params[:five], six: params[:six], status: 'wait')
					count = current_user.lucky_codes.today.null.length
					flash[:success] = "您已使用一次幸运码,静待开奖,还有#{count.to_i}次机会。"
				end
	    else
	    	flash[:success] = "您现在没有抽奖机会，请投资后再来试试运气"
	    end
		else
			flash[:success] = "请登录后操作"
		end
		redirect_to :action => 'annual_celebration'
	end

	def lucky_guess

	end

	def create_lucky_guess
		flash[:success] = "活动结束，谢谢参与。"
		redirect_to :action => 'annual_celebration'
		return
		if current_user.present?
			max_bid = current_user.bids.today.reorder("bids.invest_amount desc").first
			if max_bid.present? && max_bid.invest_amount >= 5000
				if LuckyGuess.today.where('user_id = ?', current_user.id).count == 0
					LuckyGuess.create_for(current_user.id, params[:lucky_guess])
					guess = params[:lucky_guess] == 'single' ? "单数" : "双数"
					flash[:success] = "您猜的是#{guess},静待开奖。欢迎明天再来试试手气"
					redirect_to :action => 'annual_celebration'
				else
					flash[:success] = "您今天已经猜过了，欢迎明天再来"
					redirect_to :action => 'annual_celebration'
				end
			else
				flash[:success] = '您需要投资5000元以上才能参加活动，且每天只能参加一次'
	    	redirect_to :action => 'annual_celebration'
			end
			# users = Bid.today.group_by{|bid| bid.user_id}
			# users.each_pair do |id, bid|
			# 	sort_bids = bid.sort_by{|b| b.invest_amount}
			# 	lucky_guess = LuckyGuess.where('user_id = ?', id)
			# 	if sort_bids[-1].invest_amount >= 5000 and lucky_guess.nil?
			# 		LuckyGuess.create_for(id, params[:lucky_guess])
			# 		flash[:success] = '已抽奖，请明天再来试试运气'
			# 		redirect_to :action => 'lucky_guess'
			#     else
			#     	flash[:success] = '您现在没有抽奖机会了'
			#     	redirect_to :action => 'lucky_guess'
			#     end
			# end
		else
			flash[:success] = "请登录后操作"
			redirect_to :action => 'annual_celebration'
		end
	end

	def huodong_comment

	end

	def create_huodong_comment
		flash[:success] = "活动结束，谢谢参与。"
		redirect_to :action => "annual_celebration"
		return
		if current_user.present?
			max_bid = current_user.bids.today.reorder("bids.invest_amount desc").first
			comment_records =  current_user.huodong_comments
			if max_bid.present? && max_bid.invest_amount.to_f >= 5000
				if comment_records.blank?
					CashFlow.prize current_user, 10
					HuodongComment.create_for(current_user, params[:comment], 1)
					flash[:success] = "成功评论,获得10元红包"
				else
					HuodongComment.create_for(current_user, params[:comment], 0)
					flash[:success] = "成功评论"
				end
			else
				flash[:success] = "您需要单笔投资5000元以上才能参加此活动，第一次成功评论可以获得10元红包奖励"
			end
			redirect_to :action => "annual_celebration"
		else
			flash[:success] = "请登录后操作"
			redirect_to :action => "annual_celebration"
		end
	end

	def annual_celebration
		@all_comments = HuodongComment.all
		@lucky_people = LuckyCode.win.order("id desc")
	end

	def double12

	end

	def newyear_egg
		bids = Bid.joins(:loan).where(["bids.created_at > ? and bids.created_at < ? and loans.pass = ''", DateTime.new(2015, 12, 29), DateTime.new(2016, 2, 5)])
		bids = bids.group_by{|bid| bid.user_id}.sort_by do |h|
			user_id, bs = h
			bs.sum(&:invest_amount)
		end
		@bids = bids.reverse[0..7]
	end

	def newyear_egg_api
		if Date.today < Date.new(2015, 12, 29) || Date.today > Date.new(2016, 2, 4)
			render text: '本次活动2015年12月29日开始, 2016年2月4日结束'
		else
			if current_user.present? && params[:egg].present?
				count = current_user.newyear_eggs.today.count
				if count < 3
					egg = NewyearEgg.create_for(current_user, params[:egg].to_i)
					render text: "您砸中了#{params[:egg]}元红包，投资后就可以获得红包哦"
				else
					render text: "今天的机会已用完了，明天再来吧。投资后就可以获得红包哦"
				end
			else
				render text: '请登录后，刷新页面参与活动'
			end
		end
	end

	#两周内庆
	def two_yr_anniversary

	end

	#更新两周年庆的活动字段
	def two_yr_circle_prize
		prize = current_user.two_yr_circle_records.today_create.not_actived.order('id asc').first
		if prize.present?
			prize.update_attribute(:actived_at, Time.now)
			next_angle = current_user.two_yr_circle_records.today_create.not_actived.order('id asc').first
			if next_angle.present?
				render :text => next_angle.angle
			else
				render :text => '-1'
			end
		else
			render :text => '-1'
		end
	end

	#两周年转盘活动后续
	def two_yr_aug_camp
		
	end

	# 平台活动
  # @param [Integer] 活动号
  def static
    render :template => "/campaigns/#{params[:id].to_s}.html.erb"
  end

end