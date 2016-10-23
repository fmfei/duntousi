# encoding: utf-8
class Account::CashFlowsController < Account::BaseController

  # 交易记录
  def index
    @cash_flows = current_user.cash_flows.order('id desc').paginate :page => params[:page], :per_page => 20
  end

end