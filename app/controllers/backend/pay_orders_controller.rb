# encoding: utf-8
class Backend::PayOrdersController < Backend::BaseController

  # 充值记录
  def index
    @q = PayOrder.succeed.order("id desc").ransack(params[:q])
    if params[:download].present?
      export_orders @q.result
      return
    else
      @pay_orders = @q.result.paginate(:page => params[:page], :per_page => 20)
      @amount = @q.result.sum(:amount)
      @title = '线上充值记录'
    end
  end

  def export_orders pay_orders
    if pay_orders.present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet
      sheet1.row(0).push("编号", "邮箱", "姓名", "金额", "创建时间", "更新时间", "成功")
      pay_orders.each_with_index do |order, i|
        sheet1.row(i + 1).push(
          order.id,
          order.user.email,
          order.user.name,
          order.amount,
          order.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          order.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
          (order.success ? '是' : '否')
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "pay_orders#{Time.now.strftime('%x')}.xls" )
    end
  end

  # 充值管理
  def manage
    @q = Role.find_by_name('投资人').users.reorder("users.id desc").joins(:info).ransack(params[:q])
    @lenders = @q.result.paginate(:page => params[:page], :per_page => 20)
    @title = '后台充值/扣款'
  end

  def backend_recharges
    @q = CashFlow.with_description(Dict::CashFlowDescription.backend_recharge).order('created_at desc').ransack(params[:q])
    if params[:download].present?
      export_recharges @q.result
      return
    else
      @title = '后台充值记录'
      @backend_recharges = @q.result.paginate(:page => params[:page], :per_page => 20)
      @amount = @q.result.sum(:amount)
    end
  end

  def modify_addition
    if params[:id].present?
      @cash_flow = CashFlow.find params[:id]
    else
      redirect_to :back
    end
  end

  def update_addition
    cash_flow = CashFlow.find params[:id]
    cash_flow.addition = params[:addition]
    cash_flow.save
    redirect_to :back
  end

  def export_recharges recharges
    if recharges.present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet
      sheet1.row(0).push("编号", "姓名", "金额", "说明", "充值时间")
      recharges.each_with_index do |recharge, i|
        sheet1.row(i + 1).push(
          recharge.id,
          recharge.to_user.name,
          recharge.amount,
          recharge.addition,
          recharge.created_at.strftime("%Y-%m-%d %H:%M:%S")
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "recharges#{Time.now.strftime('%x')}.xls" )
    end
  end

  # 后台充值
  def backend_recharge
    @title = '后台充值'
    @user = User.find(params[:id])
    @backend_recharge = @user.cash_flows.order('created_at desc').with_description(Dict::CashFlowDescription.backend_recharge).paginate :page => params[:page], :per_page => 20
  end

  def deducts
    @title = '后台扣款记录'
    # @deducts = CashFlow.order('id desc').with_description(Dict::CashFlowDescription.deduct).paginate :page => params[:page], :per_page => 20

    @q = CashFlow.order('id desc').with_description(Dict::CashFlowDescription.deduct).ransack(params[:q])
    @deducts = @q.result.paginate(:page => params[:page], :per_page => 20)
    @amount = @q.result.sum(:amount)
  end

  # 后台扣款
  def deduct
    @title = '后台扣款'
    @user = User.find(params[:id])
    @deducts = @user.cash_flows.order('id desc').with_description(Dict::CashFlowDescription.deduct).paginate :page => params[:page], :per_page => 20
  end

  def create_deduct
    if params[:amount].to_f <= 0.0
      redirect_to :back
      return
    end

    user = User.find(params[:user_id])
    CashFlow.deduct user, params[:amount].to_f, params[:addition]
    flash[:notice] = '扣款成功'
    redirect_to deduct_backend_pay_orders_path(id: params[:user_id])
  end

  def create_backend_recharge
    if params[:amount].to_f <= 0.0
      redirect_to :back
      return
    end
    user = User.find(params[:user_id])
    CashFlow.recharge_for user, params[:amount].to_f, nil, '', Dict::CashFlowDescription.backend_recharge, nil, params[:addition]
    redirect_to backend_recharge_backend_pay_orders_path(:id => params[:user_id])
  end

  def download
    if params[:printout].present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      @pay_orders = PayOrder.order("id desc").find(params[:printout])
      sheet1 = book.create_worksheet
      sheet1.row(0).push("编号", "邮箱", "姓名", "金额", "创建时间", "更新时间", "成功")
      @pay_orders.each_with_index do |order, i|
        sheet1.row(i + 1).push(
          order.id,
          order.user.email,
          order.user.name,
          order.amount,
          order.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          order.updated_at.strftime("%Y-%m-%d %H:%M:%S"),
          (order.success ? '是' : '否')
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "pay_orders#{Time.now.strftime('%x')}.xls" )
    else
      flash[:errors] = "请至少选择一项"
      redirect_to :back
    end
  end

end