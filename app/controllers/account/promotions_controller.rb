# encoding: utf-8
class Account::PromotionsController < Account::BaseController

  # 投标记录
  def index
		@invite_users = current_user.invite_users.paginate :page => params[:page], :per_page => 20
		# @cash_flows = CashFlow.includes(:from_user).where({to_user_id: current_user.id, cash_flow_description_id: Dict::CashFlowDescription.promote_prize.id}).paginate :page => params[:page], :per_page => 20
  end

  def circle
  	@records = current_user.circle_records.actived.paginate :page => params[:page], :per_page => 20
  end

  def egg
    @records = current_user.egg_records.paginate :page => params[:page], :per_page => 20
  end

  def box
    @records = current_user.zhongqiu_records.paginate :page => params[:page], :per_page => 20
  end

  def lucky_code
    @lucky_codes = current_user.lucky_codes.not_null.paginate :page => params[:page], :per_page => 20
  end

  def lucky_guess
    @lucky_guesses = current_user.lucky_guesses.paginate :page => params[:page], :per_page => 20
  end

  def newyear_egg
    @newyear_eggs = current_user.newyear_eggs.order("id desc").paginate :page => params[:page], :per_page => 20
  end

  def spring
    @coupons = current_user.coupons.order('id desc')
  end

  def two_yr_anniversary
    @records = current_user.two_yr_circle_records.actived.paginate :page => params[:page], :per_page => 15
  end

  def cash
    @records = current_user.bonus.cash.paginate :page => params[:page], :per_page => 15
  end

  def actual_object
    @records = current_user.bonus.actual_object.paginate :page => params[:page], :per_page => 15
  end

  def bribery_money
    @records = current_user.bonus.bribery_money.paginate :page => params[:page], :per_page => 15
  end

end