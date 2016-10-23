# encoding: utf-8
class Repayment < ActiveRecord::Base
  # attr_accessible :amount, :due_date, :interest_amount, :late_days, :month_index, :paid_at, :paid_by_platform, :principal, :state, :user_id, :loan_id, :left_principal
  STATE = ['unpaid', 'paid']

  belongs_to :user
  belongs_to :loan
  has_many :collections

  scope :unpaid, lambda{where("state = 'unpaid'")}
  scope :paid, lambda{where("state = 'paid'")}
  scope :need_pay, ->{unpaid.where('due_date <= ?', Date.today)}

  def self.generate_for loan
    self.transaction do
      case loan.repay_style
      when 'equal'
        repayments = LoanUtils.equal_repayments_table(loan.amount, loan.months, loan.monthly_interest)
        repayments.each do |month_index, repayment|
          self.create(:loan_id => loan.id,
                      :user_id => loan.borrower.id,
                      :amount => (repayment[:seed]+repayment[:interest]),
                      :principal => repayment[:seed],
                      :left_principal => repayment[:left_seed],
                      :interest_amount => repayment[:interest],
                      :month_index => month_index,
                      :due_date => (Date.today + month_index.month))
          loan.borrower.add_not_repay_total(repayment[:seed]+repayment[:interest])
        end
      when 'interest_only'
        repayments = LoanUtils.interest_only_table(loan.amount, loan.months, loan.interest)
        repayments.each do |month_index, repayment|
          self.create(:loan_id => loan.id,
                      :user_id => loan.borrower.id,
                      :amount => (repayment[:seed]+repayment[:interest]),
                      :principal => repayment[:seed],
                      :left_principal => repayment[:left_seed],
                      :interest_amount => repayment[:interest],
                      :month_index => month_index,
                      :due_date => (Date.today + month_index.month))
          loan.borrower.add_not_repay_total(repayment[:seed]+repayment[:interest])
        end
      when 'at_due'
        repayment = LoanUtils.repay_at_due_table(loan.amount, loan.months, loan.interest)
        self.create(:loan_id => loan.id,
                    :user_id => loan.borrower.id,
                    :amount => (repayment[:seed]+repayment[:interest]),
                    :principal => repayment[:seed],
                    :left_principal => 0.0,
                    :interest_amount => repayment[:interest],
                    :month_index => 1,
                    :due_date => (Date.today + (loan.months).month))
        loan.borrower.add_not_repay_total(repayment[:seed]+repayment[:interest])
      end
    end
  end

  def send_messages status
    self.collections.each do |col|
      content = "您投资借款标【#{col.bid.loan.title}】第#{col.month_index}期，已经于#{col.updated_at.to_s(:long)}完成还款#{col.amount.round(2)}元，其中本金#{col.principal.round(2)}元、利息#{col.interest.round(2)}元。感谢您对我们的关注和支持！"
      RepaymentMessage.create(receive_user_id: col.user_id, title: status, content: content, status: Dict::MessageStatus.unread.id)
    end
  end

end
