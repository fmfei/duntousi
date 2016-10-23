# encoding: utf-8
class Account::WithdrawsController < Account::BaseController

  # 提现记录
  def index
    @withdraws = current_user.withdraws.order('id desc').paginate :page => params[:page], :per_page => 20
  end

  # 提现申请
  def new
    @withdraws = current_user.withdraws.order('id desc').paginate :page => params[:page], :per_page => 20
    @withdraw = current_user.withdraws.new
  end

  def create
    if params[:withdraw][:bank].blank?
      flash[:errors] = '请选择提现银行卡'
      redirect_to new_account_withdraw_path
      return
    end
    unless current_user.trade_password == params[:trade_password]
      flash[:errors] = '提现密码错误'
      redirect_to new_account_withdraw_path
    else
      if params[:withdraw][:amount].to_f.round(2) > current_user.available.to_f.round(2)
        flash[:errors] = '提现金额不能超过可用金额。'
        redirect_to :back
        return
      end
      if params[:withdraw][:amount].to_f <= 0
        flash[:errors] = '提现金额必须为正数。'
        redirect_to :back
        return
      end
      #如果输入金额小于100或者大于50000，提示错误
      if params[:withdraw][:amount].to_f < 100 || params[:withdraw][:amount].to_f > 50000
        flash[:errors] = '提现金额应在100元到50000元之间'
        redirect_to :back
        return
      end
      bank = current_user.user_banks.find params[:withdraw][:bank]

      Withdraw.transaction do
        @withdraw = Withdraw.create_by_user current_user, params[:withdraw][:amount], bank

        CashFlow.withdraw_apply @withdraw, current_user
      end

      if @withdraw.save
        flash[:success] = '后台审核中请耐心等待。'
        redirect_to new_account_withdraw_path
      else
        flash[:errors] = @withdraw.errors
        render :new
      end
    end
  end

end