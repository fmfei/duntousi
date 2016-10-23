# encoding: utf-8

class Backend::LendersController < Backend::BaseController
	def index
		if params[:q].present?
			@lenders = Role.find_by_name('投资人').users.reorder("created_at desc").simple_search(params[:q]).paginate(:page => params[:page], :per_page => 20)
		else
			@lenders = Role.find_by_name('投资人').users.reorder("created_at desc").paginate(:page => params[:page], :per_page => 20)
		end
		@title = '出借人基本管理'
	end

	def show
		@lender = User.find(params[:id])
		@cash_flows = @lender.cash_flows.order('created_at desc').paginate :page => params[:page1], :per_page => 20
		@upcomings = @lender.collections.unpaid.order("due_date").paginate :page => params[:page2], :per_page => 20
	end

	def branch
		condition = ''
		if current_user.source.present?
			condition += "users.source = '#{current_user.source.to_s}'"
			if current_user.channel.present?
				condition += " and users.channel = '#{current_user.channel}'"
			end
		else
			condition += 'users.source is not null'
		end
		if params[:q].present?
			@lenders = Role.find_by_name('投资人').users.where("#{condition}").reorder("created_at desc").simple_search(params[:q]).paginate(:page => params[:page], :per_page => 20)
		else
			@lenders = Role.find_by_name('投资人').users.where("#{condition}").reorder("created_at desc").paginate(:page => params[:page], :per_page => 20)
		end
		@title = '用户列表'
	end

end
