class RookieLoan < ActiveRecord::Base
  belongs_to :state, :class_name => "Dict::LoanState", :foreign_key => "loan_state_id"
  belongs_to :senior_auditor, :class_name => "User", :foreign_key => "senior_auditor_id"
  has_many :rookie_bids

  default_scope {order("id desc")}
  scope :can_be_invest, -> {where(["loan_state_id in (?)", Dict::LoanState.where("name = 'bidding'").map(&:id)])}
  scope :can_be_seen, -> {where(["loan_state_id in (?)", Dict::LoanState.where(["name in (?)",['wait_to_bid', 'bidding', 'failed', 'bids_auditing', 'repaying', 'overdue', 'finished']]).map(&:id)])}

  def self.update_available_amount loan, invest_amount
    RookieLoan.transaction do
      loan.update_attribute(:available_amount, (loan.available_amount.to_f-invest_amount.to_f))
      # 满标
      if loan.available_amount == 0
        loan.update_attributes(:loan_state_id => Dict::LoanState.finished.id)

      end
    end
  end

end
