# encoding: utf-8
class Account::PayOrdersController < Account::BaseController

  before_action :check_realname

  def check_realname
    if current_user.auth_realname != 1
      redirect_to real_name_account_users_path
    end
  end
  # 充值记录
  def index
    @pay_orders = current_user.pay_orders.succeed.order('id desc').paginate :page => params[:page], :per_page => 20
    @title = ''
  end

  def index_offline
    @offline_recharges = current_user.offline_recharges.order('id desc').paginate :page => params[:page], :per_page => 20
  end

  # 充值
  def new
    @title = '线上充值'
    @pay_order = PayOrder.new
  end

  def create
    if (params[:pay_order][:amount].to_f < 10)
      flash[:errors] = "最小充值金额为10元"
      redirect_to :back
      return
    end
    @pay_money = params[:pay_order][:amount].to_f
    pay_order = current_user.pay_orders.create( :amount => @pay_money,
                                                :callback_path => account_recharge_path,
                                                :callback_model => current_user,
                                                :callback_model_method => "nil?")
    if pay_order.errors.blank?
      if !Utils.production?
        pay_url = "http://" + request.host_with_port + "/user/finish_payment/#{pay_order.uuid}/#{params[:pay_order][:pay_class]}/0"
      else
        callback = "http://" + request.host_with_port + "/user/finish_payment/#{pay_order.uuid}"
        pay_url = ThirdPay.request_url(params["pay_order"]["pay_class"], pay_order, callback)
      end
      redirect_to pay_url
    else
      flash[:errors] = pay_order.errors
      redirect_to :back
    end
  end

  def offline_recharge
    @title = '线下充值'
    @offline_recharge = OfflineRecharge.new
    @banks = OfflineBank.on
  end

  def create_offline_recharge
    if offline_recharge_params[:offline_bank_id].blank? || offline_recharge_params[:amount].blank?
      flash[:errors] = '请填写正确金额，并选择充值银行'
      redirect_to :back
      return
    end
    OfflineRecharge.transaction do
      bank = OfflineBank.find(offline_recharge_params[:offline_bank_id])
      @offline_recharge = OfflineRecharge.create(offline_recharge_params)
      @offline_recharge.update_attributes({:user => current_user,
                                          :bank_name => bank.name,
                                          :bank_detail => bank.detail})
    end

    if @offline_recharge.errors.present?
      flash[:errors] = @offline_recharge.errors
    else
      flash[:success] = '申请成功，请耐心等待审核。'
    end
    redirect_to :back
  end

  private
   def offline_recharge_params
     params.require(:offline_recharge).permit(:offline_bank_id, :amount, :comment)
   end

end