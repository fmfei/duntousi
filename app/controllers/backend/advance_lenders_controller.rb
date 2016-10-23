# encoding: utf-8
class Backend::AdvanceLendersController < Backend::BaseController
  def index
    @title = '出借人管理'

    @q = User.lender.ransack(params[:q])
    @lenders = @q.result.includes(:info).reorder('id desc').paginate :page => params[:page], :per_page => 20

    # if params[:q].present?
    #   @lenders = Role.find_by_name('投资人').users.reorder("created_at desc").simple_search(params[:q]).paginate(:page => params[:page], :per_page => 20)
    # else
    #   @lenders = Role.find_by_name('投资人').users.reorder("created_at desc").paginate(:page => params[:page], :per_page => 20)
    # end
  end

  def show
    @lender = User.find(params[:id])
    @cash_flows = @lender.cash_flows.order("created_at desc").paginate :page => params[:page1], :per_page => 20
    @upcomings = @lender.collections.unpaid.order("due_date").paginate :page => params[:page2], :per_page => 20
    @bids = @lender.bids.reorder("created_at desc").paginate :page => params[:page3], :per_page => 20

    @q = @lender.cash_flows.all_recharges.order('id desc').ransack(params[:q])
    @recharges = @q.result.paginate :page => params[:page4], :per_page => 20

    @w = @lender.withdraws.order('id desc').ransack(params[:q])
    @withdraws = @w.result.paginate :page => params[:page5], :per_page => 20

    @coupons = @lender.coupons
  end

  def new
    @title = '添加出借人'
    @lender = User.new
  end

  def create
    @lender = User.new(user_params)
    @lender.roles << Role.find_by_name('投资人')
    @lender.auth_mobile = true
    if @lender.save
      flash[:success] = '添加成功'
      redirect_to backend_advance_lenders_path
    else
      flash[:errors] = @lender.errors
      render :new
    end
  end

  def update
    lender = User.find(params[:id])
    info = lender.info
    if info.update_attributes(lender_params)
      flash[:success] = '修改成功'
      redirect_to :back
    else
      flash[:errors] = info.errors
      redirect_to :back
    end
  end

  def auth_realname_pass
    @lender = User.find(params[:id])
    return render :json => @lender.auth_realname_pass(params[:pass])
  end

  def modify
    lender = User.find(params[:id])
    pre_lender = User.find_by_mobile(params[:user][:mobile])
    if pre_lender.present? && pre_lender.id != lender.id
      flash[:errors] = '该手机号已被其他用户注册，不可用'
    else
      if lender.update_attributes(lender_params2)
        flash[:success] = '修改成功'
      else
        flash[:errors] = lender.errors
      end
    end
    redirect_to :back
  end

  def change_pass
    lender = User.find(params[:id])
    lender.password = lender.password_confirmation = params[:user][:password]
    lender.save
    redirect_to :back
  end

  def create_coupon
    # lender = User.find(params[:id])
    Coupon.create_for(params[:id], params[:amount], params[:count])
    redirect_to :back
  end

  def export_users amount=50000
    Spreadsheet.client_encoding = 'UTF-8'
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet
    sheet1.row(0).push("姓名", "手机号", "累计投资金额", "注册时间")

    cashes = UserCash.includes(:user).where('invest_total >= ?', amount)

    cashes.each_with_index do |cash, i|
      sheet1.row(i + 1).push(
        cash.user.username,
        cash.user.mobile,
        cash.invest_total.to_f.round(2),
        cash.created_at.strftime("%Y-%m-%d %H:%M:%S")
      )
    end
    str_io = StringIO.new
    book.write(str_io)
    send_data(str_io.string, :filename => "users#{Time.now.strftime('%x')}.xls" )

  end

  def show_loan_invest_info
    @bids = Loan.find(params[:id]).bids
  end

  private
    def lender_params
      params.require(:user_info).permit(:phone)
    end

    def lender_params2
      params.require(:user).permit(:mobile)
    end

    def user_params
      params.require(:user).permit(:mobile, :password, :password_confirmation)
    end

end
