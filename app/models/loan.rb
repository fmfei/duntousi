# coding: utf-8
class Loan < ActiveRecord::Base
  # attr_accessible :amount, :user_id, :available_amount, :bids_audit_time, :bids_auditor_id, :credit_level, :desc, :due_date, :interest, :junior_audit_time, :junior_auditor_id, :max_invest, :min_invest, :months, :repay_style, :senior_audit_time, :senior_auditor_id, :title, :with_guarantee, :with_mortgage, :loan_state_id, :avatar, :estimated_time, :avatar_display, :code
  belongs_to :borrower, :class_name => "User", :foreign_key => "user_id"
  belongs_to :state, :class_name => "Dict::LoanState", :foreign_key => "loan_state_id"
  belongs_to :junior_auditor, :class_name => "User", :foreign_key => "junior_auditor_id"
  belongs_to :senior_auditor, :class_name => "User", :foreign_key => "senior_auditor_id"
  belongs_to :bids_auditor, :class_name => "User", :foreign_key => "bids_auditor_id"
  has_many :bids
  has_many :repayments
  mount_uploader :avatar, AvatarUploader

  scope :of_state, lambda{|loan_state_id| where(["loan_state_id = ?", loan_state_id]) }
  scope :state_in, lambda{|states| where(["loan_state_id in (?)", states])}
  scope :can_be_seen, -> {where(["loan_state_id in (?)", Dict::LoanState.where(["name in (?)",['wait_to_bid', 'bidding', 'failed', 'bids_auditing', 'repaying', 'overdue', 'finished']]).map(&:id)])}
  scope :bidding_or_after, -> {where(["loan_state_id in (?)", Dict::LoanState.where(["name in (?)",['bidding', 'failed', 'bids_auditing', 'repaying', 'overdue', 'finished']]).map(&:id)])}
  scope :going_to_bidding, -> { where(loan_state_id: Dict::LoanState.wait_to_bid.id) }
  scope :success, -> {}
  scope :booked, -> {where("pass is not null")} # 约标密码
  REPAYSTYLE = { '按月分期还款' => 'equal', '按月还息，到期还本' => 'interest_only', '到期归还本息' => 'at_due'}
  REPAYSTYLE1 = { '按月还息，到期还本' => 'interest_only', '到期归还本息' => 'at_due'}

  validates :amount, presence: true
  validates :months, presence: true
  validates :interest, presence: true
  validates :user_id, presence: true
  def self.total_amount
    Loan.sum(:amount)
  end

  def progress
    if amount.to_f > 0
      a=(amount - available_amount).to_f / amount * 100
    else
      a=0
    end
    (a > 99.99 and a < 100) ? 99.99 : a.round(2)
  end

  def self.update_available_amount loan, invest_amount
    Loan.transaction do
      loan.update_attribute(:available_amount, (loan.available_amount.to_f-invest_amount.to_f))
      # 满标
      if loan.available_amount == 0
        # loan.update_attribute(:loan_state_id, Dict::LoanState.bids_auditing.id)
        # loan.bids.update_all("status = 'bids_auditing'")

        loan.update_attributes(:loan_state_id => Dict::LoanState.repaying.id,
                                # :bids_auditor_id =>current_user.id,
                                :bids_audit_time => Time.now)
        # 放款给借款人
        CashFlow.transfer_to_borrower loan

        # 借款人提现
        CashFlow.borrower_withdraw loan

        # 生成repayments
        Repayment.generate_for loan

        # 生成collection
        Collection.generate_for loan

        # 更新bids
        loan.bids.update_all(status:'repaying')
        loan.bids.each{|bid| bid.update_cash}
        #向投资人发送站内信
        loan.send_messages("复审通过")

        # 发放奖励
        Resque.enqueue(PromotionJob, :prize, loan.id)

      end
    end
  end

  # 截标
  def cut_off
    Loan.transaction do
      if self.available_amount > 0 && self.available_amount != self.amount

        self.update_attributes(:loan_state_id => Dict::LoanState.repaying.id,
                               :bids_audit_time => Time.now,
                               :amount => self.amount - self.available_amount,
                               :available_amount => 0)
        self.reload
        # 放款给借款人
        CashFlow.transfer_to_borrower self

        # 借款人提现
        CashFlow.borrower_withdraw self

        # 生成repayments
        Repayment.generate_for self

        # 生成collection
        Collection.generate_for self

        # 更新bids
        self.bids.update_all(status:'repaying')
        self.bids.each{|bid| bid.update_cash}
        #向投资人发送站内信
        self.send_messages("复审通过")

        # 发放奖励
        Resque.enqueue(PromotionJob, :prize, self.id)

      end
    end
  end

  def monthly_interest
    self.interest / 12.00
  end

  # 流标
  def fail_bid
    self.bids.each do |bid|
      bid.set_failed
    end
  end

  # 结束
  def set_finish
    self.update_attribute(:loan_state_id, Dict::LoanState.finished.id)
    self.bids.update_all("status = 'finished'")
  end

  def self.calculator(repay_style, amount, month, year_rate)
    year_rate = year_rate.to_f
    case repay_style
    when 'equal'
      @interest = LoanUtils.equal_repayments_table(amount, month, (year_rate/12).to_f)
    when 'interest_only'
      @interest = LoanUtils.interest_only_table(amount, month, year_rate)
    when 'at_due'
      @interest = {}
      @interest['1'] = LoanUtils.repay_at_due_table(amount, month, year_rate)
    end
    return @interest
  end

  def send_messages status
    self.bids.each do |bid|
      # status = I18n.t(self.status)
      content = "您于#{bid.created_at.to_s(:long)}投标#{bid.invest_amount.round(2)}元(借款用途：#{self.title})已经#{status}，感谢您对我们的关注和支持！"
      BidMessage.create(receive_user_id: bid.user_id, title: status, content: content, status: Dict::MessageStatus.unread.id)
    end
  end

  def add_code org_code=''
    code = org_code.to_s+Time.now.strftime("%y%m%d%H%M%S%L")+"-"+self.user_id.to_s
    self.update_attributes(:code=>code)
  end

end
