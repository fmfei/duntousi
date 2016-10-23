# encoding: utf-8
class Backend::AuditsController < Backend::BaseController
  def index
    if params[:as].present?
      @search = Loan.where(:loan_state_id => params[:as].to_i).order("created_at desc").search(params[:q])
      @title = Dict::LoanState.find(params[:as]).try(:name)+"的借款"
    else
      # @search = Loan.where("loan_state_id is not null").joins(:borrower).order("created_at desc").search(params[:search])
      @search = Loan.where("loan_state_id is not null").order("created_at desc").search(params[:q])
      @title = '所有的借款'
    end
    @loans = @search.result.paginate(:page => params[:page], :per_page => 10)
  end

  def junior_audit
    @loan = Loan.find(params[:id])
  end

  def junior_audit_pass
    @loan = Loan.find params[:id]
    @loan.update_attributes(:loan_state_id => Dict::LoanState.senior_auditing.id, :junior_auditor_id =>current_user.id, :junior_audit_time => Time.now)
    redirect_to backend_audits_path(:as=>Dict::LoanState.junior_auditing)
  end

  def senior_audit
    @loan = Loan.find(params[:id])
  end

  #终审通过，状态变为等待发标
  def senior_audit_pass
    @loan = Loan.find params[:id]
    if @loan.loan_state_id == Dict::LoanState.senior_auditing.id
      @loan.update_attributes(:loan_state_id => Dict::LoanState.wait_to_bid.id,
                              :senior_auditor_id =>current_user.id,
                              :senior_audit_time => Time.now,
                              :available_amount => @loan.amount)
    end
    redirect_to backend_audits_path(:as=>Dict::LoanState.senior_auditing)
  end

  #开始发标
  def start_bidding
    @loan = Loan.find params[:id]
    if @loan.loan_state_id == Dict::LoanState.wait_to_bid.id
      @loan.update_attributes(:loan_state_id => Dict::LoanState.bidding.id)
      # 自动投标
      if @loan.pass.blank? && @loan.is_permit_autoinvest == true
        # Resque.enqueue(AutoInvestJob, :invest, @loan.id)
        AutoInvestRule.exec_for(@loan.id)
      end
    end
    redirect_to backend_audits_path(:as=>Dict::LoanState.wait_to_bid)
  end

  # 弃用，改为满标自动审核，详见loan.update_available_amount
  # 满标审核通过
  def bids_auditing_pass
    @loan = Loan.find params[:id]
    if @loan.loan_state_id == Dict::LoanState.bids_auditing.id
      Loan.transaction do
        @loan.update_attributes(:loan_state_id => Dict::LoanState.repaying.id,
                                :bids_auditor_id =>current_user.id,
                                :bids_audit_time => Time.now)
        # 放款给借款人
        CashFlow.transfer_to_borrower @loan

        # 借款人提现
        CashFlow.borrower_withdraw @loan

        # 生成repayments
        Repayment.generate_for @loan

        # 生成collection
        Collection.generate_for @loan

        # 更新bids
        @loan.bids.update_all(status:'repaying')
        @loan.bids.each{|bid| bid.update_cash}
        #向投资人发送站内信
        @loan.send_messages("复审通过")

        # 发放奖励
        Resque.enqueue(PromotionJob, :prize, @loan.id)

        # 自动投标
        # Resque.enqueue(AutoInvestJob, :invest)
      end
    end
    redirect_to backend_audits_path(:as=>Dict::LoanState.bids_auditing)
  end

  # 流标
  def fail_bid
    @loan = Loan.find(params[:id])
    if @loan.loan_state_id == Dict::LoanState.bidding.id || @loan.loan_state_id == Dict::LoanState.bids_auditing.id
      Loan.transaction do
        @loan.update_attributes(:loan_state_id => Dict::LoanState.failed.id,
                                :bids_auditor_id => current_user.id,
                                :bids_audit_time => Time.now)
        @loan.fail_bid
        #向投资人发送站内信
        @loan.send_messages("流标")
      end
    end
    redirect_to backend_audits_path(:as=>Dict::LoanState.failed)
  end

  # 截标
  def cut_off
    @loan = Loan.find(params[:id])
    if @loan.loan_state_id == Dict::LoanState.bidding.id
      @loan.cut_off
    end
    redirect_to backend_audits_path(:as=>Dict::LoanState.bidding)
  end

  def show
    @loan = Loan.find(params[:id])
    @bids = @loan.bids.includes(:user).order('id desc')
  end
  # 借款人详情
  def details
    @title = "借款人详情"
    @loan = Loan.find(params[:id])
  end
end