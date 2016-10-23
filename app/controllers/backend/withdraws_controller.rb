# encoding: utf-8
class Backend::WithdrawsController < Backend::BaseController
  def index
    @q = Withdraw.order('id desc').ransack(params[:q])
    if params[:download].present?
      export_withdraws @q.result
      return
    else
      @withdraws = @q.result.paginate :page => params[:page], :per_page => 20
      @succeed = @q.result.succeed.sum(:amount)
      @auditing = @q.result.auditing.sum(:amount)
      @title = '提现申请列表'
    end
  end

  def export_withdraws withdraws
    if withdraws.present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet
      sheet1.row(0).push("编号", "姓名", "状态", "提现金额", "到账金额", "手续费", "卡号", "银行", "支行", "审核时间", "提现时间")
      withdraws.each_with_index do |withdraw, i|
        sheet1.row(i + 1).push(
          withdraw.id,
          withdraw.user.name,
          t(withdraw.status),
          withdraw.amount.to_f.round(2),
          withdraw.received_amount.to_f.round(2),
          withdraw.fee.to_f.round(2),
          withdraw.card_number,
          withdraw.bank,
          withdraw.branch,
          withdraw.try(:audit_time).try(:strftime, "%Y-%m-%d %H:%M:%S"),
          withdraw.created_at.strftime("%Y-%m-%d %H:%M:%S")
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "withdraws#{Time.now.strftime('%x')}.xls" )
    end
  end

  def show
    @withdraw = Withdraw.find(params[:id])
    @title = '提现申请'
  end

  def new
   @withdraw = Withdraw.new
   @title = '添加角色'
  end

  def update

    @withdraw = Withdraw.find(params[:id])

    if params[:res] == 'pass'
      @withdraw.pay_lender('Ecpss', current_user)
    else
      @withdraw.return_to_lender(current_user)
    end

    respond_to do |format|
      if params[:res] == 'pass'
        format.html { redirect_to :action=>:index, notice: '放款成功.' }
        format.json { head :no_content }
      else
        format.html { redirect_to :action=>:index, notice: '取消放款.' }
        format.json { head :no_content }
      end
    end

  end

  #异步设置提现站内信提示信息
  def set_notice
    @withdraw = Withdraw.find(params[:id])
    if @withdraw.update_attributes(:notice => params[:notice])
      render :text => "添加成功！"
    else
      render :text => "添加失败！"
    end
  end

  def destroy
    @withdraw = Withdraw.find(params[:id])
    @withdraw.destroy

    respond_to do |format|
      format.html { redirect_to(backend_withdraws_path) }
      format.xml  { head :ok }
    end
  end

  def edit_multiple
    @withdraws = Withdraw.is_admin.where(['name != ?', '超级管理员'])
    @permissions = Permission.order('subject')
    @title = '配置权限'
  end

  def update_multiple
    params[:withdraws] = {} unless params.has_key?(:withdraws) # if all checkboxes unchecked.
    Withdraw.all.each do |withdraw|
      # this allows for 0 permission checkboxes being checked for a withdraw.
      unless params[:withdraws].has_key?(withdraw.id.to_s)
        params[:withdraws][withdraw.id] = { permission_ids: [] }
      end
    end
    @withdraws = Withdraw.update(params[:withdraws].keys, params[:withdraws].values)
    @withdraws.reject! { |r| r.errors.empty? }
    if @withdraws.empty?
      redirect_to edit_multiple_backend_withdraws_path
    else
      render :edit_multiple
    end
  end

  def download
    if params[:printout].present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      @withdraws = Withdraw.order("id desc").find(params[:printout])
      sheet1 = book.create_worksheet
      sheet1.row(0).push("编号", "姓名", "状态", "提现金额", "到账金额", "手续费", "卡号", "银行", "支行", "审核时间", "提现时间")
      @withdraws.each_with_index do |withdraw, i|
        sheet1.row(i + 1).push(
          withdraw.id,
          withdraw.user.name,
          t(withdraw.status),
          withdraw.amount.to_f.round(2),
          withdraw.received_amount.to_f.round(2),
          withdraw.fee.to_f.round(2),
          withdraw.card_number,
          withdraw.bank,
          withdraw.branch,
          withdraw.try(:audit_time).try(:strftime, "%Y-%m-%d %H:%M:%S"),
          withdraw.created_at.strftime("%Y-%m-%d %H:%M:%S")
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "withdraws#{Time.now.strftime('%x')}.xls" )
    else
      flash[:errors] = "请至少选择一项"
      redirect_to :back
    end
  end
end