# encoding: utf-8
class Backend::RookieLoansController < Backend::BaseController
  include_kindeditor :only => [:new, :edit]

  def index
    @title = "新手标信息"
    @loans = RookieLoan.all.paginate(:page=>params[:page],:per_page =>10)
  end

  def new
    @title = "添加新手标"
    @rookie_loan = RookieLoan.new
  end

  def create

    @loan = RookieLoan.create(loan_params)
    redirect_to action: :index
  end

  def edit
    @title = "修改借款信息"
    @rookie_loan = RookieLoan.find(params[:id])
    # @user = @loan.borrower
  end

  def update
    @loan = RookieLoan.find(params[:id])
    @loan.update_attributes(loan_params)
    redirect_to action: :index
  end

  def show
    @title = "借款信息"
    @loan = RookieLoan.find(params[:id])
    render :show
  end

  def destroy
    @loan = RookieLoan.find(params[:id])
    @loan.destroy
    redirect_to action: :index
  end

  def senior_audit
    @loan = RookieLoan.find(params[:id])
  end

  def submit_audit
    @loan = RookieLoan.find params[:id]
    @loan.update_attributes(:loan_state_id => Dict::LoanState.bidding.id,
                            :senior_auditor_id =>current_user.id,
                            :senior_audit_time => Time.now,
                            :available_amount => @loan.amount)
    redirect_to action: :index
  end

  def detail
    @loan = RookieLoan.find(params[:id])
    @bids = @loan.rookie_bids.paginate(:page=>params[:page],:per_page =>10)
  end

  private
    def loan_params
      params.require(:rookie_loan).permit(:user_id,:amount,:invest_day,:interest,:due_date,:title,:avatar_display,:desc)
    end
end