# encoding: utf-8
class Backend::CashFlowsController < Backend::BaseController
  def index
    @title = '流水明细'

    @q = CashFlow.ransack(params[:q])
    @cash_flows = @q.result.order('id desc').paginate :page => params[:page], :per_page => 20
    @amount = @q.result.sum(:amount)
    @from_users = @q.result.select("distinct from_user_id").count
    @to_users = @q.result.select("distinct to_user_id").count
    @offline_users = @q.result.select("distinct offline_user_id").count
  end

  def show
    @user = User.find params[:id]
    @cash_flows = CashFlow.order("id desc").where(["from_user_id = ? or to_user_id = ?", @user.id, @user.id]).paginate :page => params[:page], :per_page => 20
    @title = @user.name + '的流水明细'
  end

  def stat
    if params["created_at_gteq"].present?
      from = params["created_at_gteq"].to_datetime
      to = params["created_at_lteq"].to_datetime + 1.day
      repayments = Repayment.paid.where(["date(due_date) >= ? and date(due_date) <= ?", from, to])
      @principal = repayments.sum(:principal) 
      @interest = repayments.sum(:interest_amount)

      @withdraw_fee = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.withdraw_fee.id).sum(:amount).round(2)

      @promote_prize = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.promote_prize.id).sum(:amount).round(2)
      @prize_first = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.prize_first.id).sum(:amount).round(2)
      @prize_max = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.prize_max.id).sum(:amount).round(2)
      @prize_last = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.prize_last.id).sum(:amount).round(2)
      @prize_register = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.prize_register.id).sum(:amount).round(2)
      @prize_offline = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.prize_offline.id).sum(:amount).round(2)
      @prize = CashFlow.where(["date(created_at) >= ? and date(created_at) <= ?", from, to]).where(:cash_flow_description_id => Dict::CashFlowDescription.prize.id).sum(:amount).round(2)
    else
      repayments = Repayment.paid
      @principal = repayments.sum(:principal) 
      @interest = repayments.sum(:interest_amount)

      @withdraw_fee = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.withdraw_fee.id).sum(:amount).round(2)

      @promote_prize = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.promote_prize.id).sum(:amount).round(2)
      @prize_first = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.prize_first.id).sum(:amount).round(2)
      @prize_max = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.prize_max.id).sum(:amount).round(2)
      @prize_last = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.prize_last.id).sum(:amount).round(2)
      @prize_register = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.prize_register.id).sum(:amount).round(2)
      @prize_offline = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.prize_offline.id).sum(:amount).round(2)
      @prize = CashFlow.where(:cash_flow_description_id => Dict::CashFlowDescription.prize.id).sum(:amount).round(2)
    end

  end

end