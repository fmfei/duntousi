# coding: utf-8
# 资金流，资金记录
class CashFlow < ActiveRecord::Base

  belongs_to :from_user, :class_name => "User"
  belongs_to :to_user, :class_name => "User"
  belongs_to :offline_user, :class_name => 'User' # 提现时为提现用户
  belongs_to :pay_order
  belongs_to :cash_flow_description, :class_name => "Dict::CashFlowDescription"
  belongs_to :trigger, :polymorphic => true

  scope :borrower_unit, lambda{|borrower| where(["borrower_id = ?", borrower.is_a?(Fixnum) ? borrower : borrower.id])}
  scope :with_description, lambda{|description| where(["cash_flow_description_id = ?", description.id])}
  scope :time_range, lambda{|begin_at, end_at| where("created_at >= ? AND created_at < ?", begin_at, end_at)}
  scope :with_user, lambda{|user_id| where(["from_user_id = ? or to_user_id = ?", user_id, user_id])}
  scope :recharged_for, lambda{|user_id| where(["from_user_id is null and to_user_id = ? and created_at < ?", user_id, (DateTime.now-15.days)])}
  scope :all_recharges, ->{where("cash_flow_description_id in (?)", [Dict::CashFlowDescription.charge, Dict::CashFlowDescription.offline_recharge, Dict::CashFlowDescription.backend_recharge])}
  scope :withdraw_apply, ->{where(cash_flow_description_id: Dict::CashFlowDescription.withdraw_apply.id)}

  validates :amount, :total_of_from_user, :available_of_from_user, :freeze_of_from_user,
            :total_of_to_user, :available_of_to_user, :freeze_of_to_user,
            :allow_nil => true, :numericality => {:greater_than_or_equal_to => 0}

  after_create :update_cash_items

  def update_cash_items
    if self.from_user.present?
      self.update_attributes( :total_of_from_user => self.from_user.total,
                              :available_of_from_user => self.from_user.available,
                              :freeze_of_from_user => self.from_user.freeze_amount)
    end
    if self.to_user.present?
      self.update_attributes( :total_of_to_user => self.to_user.total,
                              :available_of_to_user => self.to_user.available,
                              :freeze_of_to_user => self.to_user.freeze_amount)
    end
  end

  def description
    self.try(:cash_flow_description).try(:name)
  end

  def available_of_user user
    if self.from_user_id == user.id
      self.available_of_from_user
    elsif self.to_user_id == user.id
      self.available_of_to_user
    end
  end

  # 充值
  # 投资充值
  # 还款充值
  def self.recharge_for user, amount, pay_order=nil, pay_class='', desc = Dict::CashFlowDescription.charge, trigger=nil, addition=nil

    self.transaction do
      user.add_total amount
      user.add_available amount
      user.add_recharge_total amount

      CashFlow.create(:to_user => user,
                      :offline_user => user,
                      :amount => amount,
                      :pay_order => pay_order,
                      :cash_flow_description_id => desc.id,
                      :pay_class => pay_class,
                      :trigger => trigger,
                      :addition => addition)
      if desc == Dict::CashFlowDescription.offline_recharge
        user.add_total amount*0.002
        user.add_available amount*0.002
        CashFlow.create(:to_user => user,
                        :from_user => User.company,
                        :amount => amount*0.002,
                        :pay_order => pay_order,
                        :cash_flow_description_id => Dict::CashFlowDescription.prize_offline.id,
                        :pay_class => pay_class,
                        :trigger => trigger,
                        :addition => addition)
      end
    end
  end

  # 后台扣款
  def self.deduct user, amount, addition
    if user.available < amount
      amount = user.available
    end
    self.transaction do
      user.minus_total amount
      user.minus_available amount

      CashFlow.create(:from_user => user,
                      :offline_user => user,
                      :amount => amount,
                      :cash_flow_description => Dict::CashFlowDescription.deduct,
                      :addition => addition)
    end
  end


  # 提现申请
  def self.withdraw_apply withdraw, current_user
    self.transaction do
      current_user.minus_total withdraw.amount
      current_user.minus_available withdraw.amount
      current_user.add_freeze_amount withdraw.amount

      User.agent.add_total withdraw.amount
      User.agent.add_available withdraw.amount

      CashFlow.create(:cash_flow_description => Dict::CashFlowDescription.withdraw_apply,
                      :amount => withdraw.amount,
                      :from_user => current_user,
                      :to_user=> User.agent,
                      :trigger => withdraw)
    end
  end

  # 后台提现放款
  # @param [Withdraw] 提现订单
  def self.pay_lender_for_withdraw withdraw
    self.transaction do

      User.agent.minus_total withdraw.amount
      User.agent.minus_available withdraw.amount
      withdraw.user.minus_freeze_amount withdraw.amount

      withdraw.user.add_withdraw_total withdraw.amount
      withdraw.user.add_withdraw_received withdraw.received_amount

      CashFlow.create(:from_user => User.agent,
                      :offline_user => withdraw.user,
                      :cash_flow_description => Dict::CashFlowDescription.withdraw,
                      :amount => withdraw.received_amount)
      if withdraw.fee.to_f > 0

        CashFlow.create(:from_user => User.agent,
                        :offline_user => User.company,
                        :cash_flow_description => Dict::CashFlowDescription.withdraw_fee,
                        :amount => withdraw.fee)
      end

    end
  end

  # 出借人提现失败
  def self.withdraw_return_to_lender withdraw
    self.transaction do

      withdraw.user.add_total withdraw.amount
      withdraw.user.add_available withdraw.amount
      withdraw.user.minus_freeze_amount withdraw.amount

      User.agent.minus_total withdraw.amount
      User.agent.minus_available withdraw.amount

      CashFlow.create( :from_user => User.agent,
                       :to_user => withdraw.user,
                       :cash_flow_description => Dict::CashFlowDescription.withdraw_return,
                       :amount => withdraw.amount,
                       :pay_class=>withdraw.pay_class )
    end
  end

  # 投标
  def self.create_bid user, bid, loan, pay_method = 'pay_bid'
    self.transaction do
      user.minus_available bid.invest_amount
      user.add_invest_total bid.invest_amount

      User.asset.add_total bid.invest_amount
      User.asset.add_available bid.invest_amount
      CashFlow.create(:cash_flow_description_id => Dict::CashFlowDescription.send(pay_method).id,
                      :amount => bid.invest_amount,
                      :from_user_id => user.id,
                      :to_user_id => User.asset.id,
                      :trigger => loan)
    end
  end

  # 流标
  def self.return_pay_bid bid
    self.transaction do
      bid.user.add_total bid.invest_amount
      bid.user.add_available bid.invest_amount
      bid.user.minus_invest_total bid.invest_amount

      User.asset.minus_total bid.invest_amount
      User.asset.minus_available bid.invest_amount

      CashFlow.create(:cash_flow_description_id => Dict::CashFlowDescription.return_pay_bid.id,
                      :amount => bid.invest_amount,
                      :from_user_id => User.asset.id,
                      :to_user_id => bid.user_id,
                      :trigger => bid)
    end
  end

  # 放款给借款人
  def self.transfer_to_borrower loan
    self.transaction do
      User.asset.minus_total loan.amount
      User.asset.minus_available loan.amount

      loan.borrower.add_total loan.amount
      loan.borrower.add_available loan.amount

      CashFlow.create(:cash_flow_description_id => Dict::CashFlowDescription.transfer_to_borrower.id,
                      :amount => loan.amount,
                      :from_user_id => User.asset.id,
                      :to_user_id => loan.borrower.id,
                      :trigger => loan)
    end
  end

  # 借款人提现
  def self.borrower_withdraw loan
    self.transaction do
      loan.borrower.minus_total loan.amount
      loan.borrower.minus_available loan.amount
      loan.borrower.add_loan_total loan.amount

      CashFlow.create(:from_user_id => loan.borrower.id,
                      :offline_user_id => loan.borrower.id,
                      :amount => loan.amount,
                      :cash_flow_description => Dict::CashFlowDescription.withdraw)
    end
  end

  # 借款人还款
  def self.repay_to collection
    self.transaction do
      collection.borrower.minus_total collection.amount
      collection.borrower.minus_available collection.amount

      collection.user.add_total collection.interest
      collection.user.add_available collection.amount

      CashFlow.create(:from_user_id => collection.borrower_id,
                      :to_user_id => collection.user_id,
                      :amount => collection.amount,
                      :trigger => collection,
                      :cash_flow_description_id => Dict::CashFlowDescription.repay.id)
    end
  end

  # 债权转让
  def self.sell_bid current_user, from_bid, to_bid, invest_amount
    self.transaction do
      current_user.minus_available invest_amount
      current_user.minus_total invest_amount
      current_user.add_invest_total invest_amount

      from_bid.user.add_available invest_amount
      from_bid.user.add_total invest_amount

      self.create(:cash_flow_description_id => Dict::CashFlowDescription.sell_bid.id,
                  :amount => invest_amount,
                  :from_user_id => current_user.id,
                  :to_user_id => from_bid.user_id,
                  :trigger => to_bid)

      from_bid.user.minus_available invest_amount*SystemConfig.sell_bid_fee.value.to_f
      from_bid.user.minus_total invest_amount*SystemConfig.sell_bid_fee.value.to_f
      User.company.add_available invest_amount*SystemConfig.sell_bid_fee.value.to_f
      User.company.add_total invest_amount*SystemConfig.sell_bid_fee.value.to_f

      self.create(:cash_flow_description_id => Dict::CashFlowDescription.sell_bid_fee.id,
                  :amount => invest_amount*SystemConfig.sell_bid_fee.value.to_f,
                  :from_user_id => from_bid.user_id,
                  :to_user_id => User.company.id,
                  :trigger => to_bid)
    end
  end

  # 邀请奖励
  def self.invite_prize to_user, amount, offline_user_id, bid
    User.company.minus_available amount
    User.company.minus_total amount
    to_user.add_available amount
    to_user.add_total amount

    self.create(:cash_flow_description_id => Dict::CashFlowDescription.promote_prize.id,
                :amount => amount,
                :from_user_id => User.company.id,
                :to_user_id => to_user.id,
                :offline_user_id => offline_user_id,
                :trigger => bid)
  end

  # 投标奖励
  def self.bid_prize to_user, amount, bid, desc = 'prize_first'
    User.company.minus_available amount
    User.company.minus_total amount
    to_user.add_available amount
    to_user.add_total amount

    self.create(:cash_flow_description_id => Dict::CashFlowDescription.send(desc).id,
                :amount => amount,
                :from_user_id => User.company.id,
                :to_user_id => to_user.id,
                :trigger => bid)
  end

  # 发放奖励、红包
  def self.prize to_user, amount
    self.transaction do
      User.company.minus_available amount
      User.company.minus_total amount
      to_user.add_available amount
      to_user.add_total amount

      self.create(:cash_flow_description_id => Dict::CashFlowDescription.prize.id,
                  :amount => amount,
                  :from_user_id => User.company.id,
                  :to_user_id => to_user.id)
    end
  end

  # 一元购
  def self.create_yiyuangou user, order, amount
    self.transaction do
      user.minus_available amount
      user.minus_total amount

      User.company.add_total amount
      User.company.add_available amount

      CashFlow.create(:cash_flow_description_id => Dict::CashFlowDescription.yiyuangou.id,
                      :amount => amount,
                      :from_user_id => user.id,
                      :to_user_id => User.company.id,
                      :trigger => order)
    end

  end

  #新手标
  def self.create_rookie bid
    self.transaction do
      bid.user.add_available bid.collection_interest
      bid.user.add_total bid.collection_interest
      
      User.company.minus_total bid.collection_interest
      User.company.minus_available bid.collection_interest

      CashFlow.create(:cash_flow_description_id => Dict::CashFlowDescription.rookie_bid.id,
                      :amount => bid.collection_interest,
                      :from_user_id => User.company.id,
                      :to_user_id => bid.user.id,
                      :trigger => bid)
    end
  end

end
