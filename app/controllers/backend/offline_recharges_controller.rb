#encoding:utf-8
class Backend::OfflineRechargesController < Backend::BaseController

  def index
    @q = OfflineRecharge.order("id desc").ransack(params[:q])
    if params[:download].present?
      export_recharges @q.result
      return
    else
      @title = '线下充值记录'
      @offline_recharges = @q.result.paginate(:page => params[:page], :per_page => 20)
      @amount = @q.result.success.sum(:amount)
      @permit = @q.result.success.sum(:permit_amount)
    end
  end

  def export_recharges charges
    if charges.present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet

      sheet1.row(0).push("编号", "姓名", "金额", "批准金额", "用户备注", "充值银行", "申请时间", "审核人", "审核备注", "审核时间", "状态")
      charges.each_with_index do |recharge, i|
        sheet1.row(i + 1).push(
          recharge.id,
          recharge.user.name,
          recharge.amount,
          recharge.permit_amount,
          recharge.comment,
          recharge.offline_bank.detail,
          recharge.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          recharge.try(:auditor).try(:email),
          recharge.auditor_comment,
          recharge.try(:audit_time).try(:strftime, "%Y-%m-%d %H:%M:%S"),
          recharge.status_name
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "charges#{Time.now.strftime('%x')}.xls" )
    end
  end

  def wait_audit
    @title = '线下充值审核'
    @offline_recharges = OfflineRecharge.need_audit.order("created_at asc").paginate(:page => params[:page], :per_page => 20)
  end

  def edit
    @title = '充值审核'
    begin
      @offline_recharge = OfflineRecharge.need_audit.find(params[:id])
    rescue Exception => e
      redirect_to wait_audit_backend_offline_recharges_path
    end
  end

  def update
    @offline_recharge = OfflineRecharge.need_audit.find(params[:id])

    respond_to do |format|
      if @offline_recharge.update_attributes(offline_recharges_params)
        OfflineRecharge.transaction do
          @offline_recharge.update_attributes(auditor: current_user,
                                              audit_time: Time.now)
          @offline_recharge.succeed if offline_recharges_params[:status] == '1'
        end
        format.html { redirect_to wait_audit_backend_offline_recharges_path, notice: '审核成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @offline_recharge.errors, status: :unprocessable_entity }
      end
    end
  end

  private
   def offline_recharges_params
     params.require(:offline_recharge).permit(:status, :permit_amount, :auditor_comment)
   end

end
