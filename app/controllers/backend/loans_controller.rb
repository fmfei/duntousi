# encoding: utf-8
class Backend::LoansController < Backend::BaseController
  include_kindeditor :only => [:new, :edit]

  def index
    @title = "借款信息"
    @search = Loan.where("loan_state_id is null").ransack(params[:q])
    @loans = @search.result.includes(:borrower =>[:info]).order('id desc').paginate(:page=>params[:page],:per_page =>10)
    # @loans = Loan.includes(:borrower=>[:info]).where("loan_state_id is null").order('id desc').paginate(:page => params[:page], :per_page => 10)
  end

  def new
    @title = "添加借款信息"
    @user = User.find(params[:user_id])
    unless @user
      redirect_to action: :index
    end
  end

  def create
    @loan = Loan.create(loan_params)
    if @loan.id.present? 
      org_code = Organization.exists?(params[:organization]) ? Organization.find(params[:organization]).code : ""
      @loan.add_code(org_code)
    end
    redirect_to action: :index
  end

  def edit
    @title = "修改借款信息"
    @loan = Loan.find(params[:id])
    @user = @loan.borrower
  end

  def update
    @loan = Loan.find(params[:id])
    @loan.update_attributes(loan_params)
    unless params[:audit].present?
      redirect_to action: :index
    else
      redirect_to backend_audits_path(:as=>params[:audit])
    end
  end

  def show
    @title = "借款信息"
    @loan = Loan.find(params[:id])
    render :show
  end

  def destroy
    @loan = Loan.find(params[:id])
    @loan.destroy
    redirect_to action: :index
  end

  def submit_audit
    @loan = Loan.find(params[:id])
    @loan.update_attributes(:loan_state_id => Dict::LoanState.junior_auditing.id)
    redirect_to action: :index
  end

  private
    def loan_params
      params.require(:loan).permit(:user_id,:amount,:months,:interest,:repay_style,:min_invest,
        :max_invest,:due_date,:estimated_time,:title,:credit_level,:with_mortgage,:with_guarantee,:avatar_display,:desc, :pass, :is_permit_autoinvest)
    end
end