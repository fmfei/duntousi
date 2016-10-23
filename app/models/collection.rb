class Collection < ActiveRecord::Base
  # attr_accessible :amount, :bid_id, :borrower_id, :due_date, :interest, :month_index, :paid_at, :principal, :repay_state, :repayment_id, :user_id
  REPAY_STATE = ['unpaid', 'paid']
  belongs_to :bid
  belongs_to :user
  belongs_to :repayment
  belongs_to :borrower, :class_name => 'User'

  default_scope { where(:removed => false) }
  scope :unpaid, -> { where("repay_state = 'unpaid'")}
  scope :paid, -> {where("repay_state = 'paid'")}

  def self.generate_for loan
    self.transaction do
      loan.repayments.each do |repayment|
        loan.bids.includes(:user).each do |bid|
          self.create(:user_id => bid.user_id,
                      :bid_id => bid.id,
                      :repayment_id => repayment.id,
                      :borrower_id => loan.user_id,
                      :amount => repayment.amount*(bid.invest_amount / loan.amount.to_f),
                      :principal => repayment.principal*(bid.invest_amount / loan.amount.to_f),
                      :interest => repayment.interest_amount*(bid.invest_amount / loan.amount.to_f),
                      :due_date => repayment.due_date,
                      :month_index => repayment.month_index)
          bid.user.add_not_collection_principal(repayment.principal*(bid.invest_amount / loan.amount.to_f))
          bid.user.add_not_collection_interest(repayment.interest_amount*(bid.invest_amount / loan.amount.to_f))
          bid.user.add_not_collection_total(repayment.amount*(bid.invest_amount / loan.amount.to_f))
        end
      end
    end
  end

  def pay
    self.update_attribute(:repay_state, 'paid')
    CashFlow.repay_to self

    # 短信通知投资人
    Resque.enqueue(SmsJob, :send_repay_notice, self.user.mobile, self.amount.to_f.round(2))

    self.user.minus_not_collection_principal(self.principal)
    self.user.minus_not_collection_interest(self.interest)
    self.user.minus_not_collection_total(self.amount)
    self.user.add_collected_interest(self.interest)

    self.bid.add_colected_amount(self.amount)
    self.bid.add_collected_interest(self.interest)
    self.bid.minus_not_collected_amount(self.amount)
    self.bid.minus_not_collected_interest(self.interest)

  end

  # @@@@@@@ 债权转让 @@@@@@@@@@@@@
  def self.generate_for_bid from_bid, to_bid, current_user
    from_bid_unpaid_principal = from_bid.collections.unpaid.sum(:principal)
    percent = to_bid.invest_amount / from_bid_unpaid_principal
    from_bid.collections.unpaid.each do |collection|
      self.create(:user_id => to_bid.user_id,
                  :bid_id => to_bid.id,
                  :repayment_id => collection.repayment_id,
                  :borrower_id => collection.borrower_id,
                  :amount => collection.amount*percent,
                  :principal => collection.principal*percent,
                  :interest => collection.interest*percent,
                  :due_date => collection.due_date,
                  :month_index => collection.month_index)
      current_user.add_not_collection_principal(collection.principal*percent)
      current_user.add_not_collection_interest(collection.interest*percent)
      current_user.add_not_collection_total(collection.amount*percent)
    end
  end

  # 调整原始债权的 还款
  def self.update_unpaid from_bid, to_bid
    from_bid_unpaid_principal = from_bid.collections.unpaid.sum(:principal)
    percent = 1 - to_bid.invest_amount / from_bid_unpaid_principal
    percent2 = to_bid.invest_amount / from_bid_unpaid_principal
    from_bid.collections.unpaid.each do |collection|
      if to_bid.invest_amount == from_bid.invest_amount
        collection.update_attribute(:removed, true)
      end
      collection.update_attributes( :amount => collection.amount*percent,
                                    :principal => collection.principal*percent,
                                    :interest => collection.interest*percent
                                    )
      from_bid.user.minus_not_collection_principal(collection.principal*percent2)
      from_bid.user.minus_not_collection_interest(collection.interest*percent2)
      from_bid.user.minus_not_collection_total(collection.amount*percent2)
    end
  end


  # @@@@@@@ 债权转让结束 @@@@@@@@@@
end
