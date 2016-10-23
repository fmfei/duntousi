# coding: utf-8
class Bid < ActiveRecord::Base
  # attr_accessible :colected_amount, :collected_interest, :collection_amount, :finished, :interest, :invest_amount, :invest_month, :loan_id, :not_collected_amount, :not_collected_interest, :status, :user_id, :user
  STATUS = {'投标中' => "bidding", '流标' => "failed", '复审中' => 'bids_auditing', '还款中' => 'repaying', '逾期' => 'overdue', '还款完成' => 'finished'}
  STATISTIC_NEED = {'投标中' => "bidding", '流标' => "failed", '复审中' => 'bids_auditing', '还款中' => 'repaying', '还款完成' => 'finished'}
  MIN_SELL_AMOUNT = 100.00 # 最小债权转让金额

  belongs_to :user
  belongs_to :loan
  has_many :collections
  belongs_to :from_bid, :class_name => 'Bid'
  has_many :to_bids, :class_name => 'Bid', :foreign_key => :from_bid_id

  default_scope { order("id asc") }
  scope :bidding, -> {where(:status => 'bidding')}
  scope :repaying, -> {where(:status => 'repaying')}
  scope :finished, -> {where(:status => 'finished')}

  scope :status_in, lambda{|status| where(["status in (?)", status])}
  scope :can_be_sold, -> { where('(not_collected_amount - not_collected_interest) >= ?', MIN_SELL_AMOUNT) }
  scope :for_sale, -> { where(:for_sale => true) }
  scope :bought_from_bid, -> { where('from_bid_id is not null') }
  scope :sold, -> { where('sold_amount > 0') }
  scope :auto_invest, -> { where(:auto_invest => true)}
  scope :manual, -> { where(:auto_invest => false) }
  scope :today, -> {where("date(created_at) = ?", Date.today)}

  CASHES = {
            '应收总额' => 'collection_amount',
            '已收总额' => 'colected_amount',
            '已收利息' => 'collected_interest',
            '待收总额' => 'not_collected_amount',
            '待收利息' => 'not_collected_interest'
          }


  def self.create_by_user current_user, loan_id, invest_amount
    self.transaction do
      loan = Loan.find(loan_id)
      if loan.loan_state_id == Dict::LoanState.bidding.id

        bid = self.create(:user => current_user,
                          :loan_id => loan_id,
                          :invest_amount => invest_amount.to_f.round(2),
                          :invest_month => loan.months,
                          :interest => loan.interest,
                          :status => 'bidding')
        CashFlow.create_bid current_user, bid, loan
        Loan.update_available_amount(loan, invest_amount.to_f.round(2))
      end
    end
  end

  def self.auto_invest_by_user current_user, loan_id, invest_amount
    self.transaction do
      loan = Loan.find(loan_id)
      if loan.loan_state_id == Dict::LoanState.bidding.id

        if invest_amount.to_f > current_user.available.to_f
          raise '账户余额不足'
        end
        if loan.min_invest.present? && invest_amount.to_f < loan.min_invest
          raise "投资金额不能小于#{loan.min_invest}"
        end
        if loan.min_invest.present? && (loan.available_amount < 2 * loan.min_invest) && (invest_amount.to_f < loan.available_amount)
          raise "当前标的可投金额为#{loan.available_amount}元，请一次投满。"
        end

        if loan.min_invest.present? && (loan.available_amount > 2 * loan.min_invest) && (loan.available_amount > invest_amount.to_f) && ((loan.available_amount - invest_amount.to_f) < loan.min_invest)
          invest_amount = loan.available_amount - loan.min_invest
        end

        if loan.max_invest.present? && loan.min_invest.present? && invest_amount.to_f > (loan.max_invest - loan.min_invest) && invest_amount.to_f < loan.max_invest
          invest_amount = loan.max_invest - loan.min_invest
        end

        if loan.max_invest.present? && invest_amount.to_f > loan.max_invest
          invest_amount = loan.max_invest
        end

        if invest_amount.to_f > loan.available_amount
          invest_amount = loan.available_amount
        end

        bid = self.create(:user => current_user,
                          :loan_id => loan_id,
                          :invest_amount => invest_amount.to_f,
                          :invest_month => loan.months,
                          :interest => loan.interest,
                          :status => 'bidding',
                          :auto_invest => true)
        CashFlow.create_bid current_user, bid, loan, 'auto_pay_bid'
        Loan.update_available_amount(loan, invest_amount)
      end
    end
  end

  # 未收本金
  def not_collected_principal
    self.not_collected_amount - self.not_collected_interest
  end

  # 流标
  def set_failed
    CashFlow.return_pay_bid self
    self.update_attribute(:status, 'failed')
  end

  # 更新各现金字段
  def update_cash
    self.update_attribute(:collection_amount, self.collections.sum(:amount))
    self.update_attribute(:not_collected_amount, self.collections.unpaid.sum(:amount))
    self.update_attribute(:not_collected_interest, self.collections.unpaid.sum(:interest))
  end

  def category
    self.auto_invest ? '自动投标' : '手动投标'
  end

  CASHES.values.each do |type|
    {'add' => '+', 'minus' => '-'}.each do |key, value|
      # 例如： add_total
      define_method "#{key}_#{type}" do |amount|
        # 防止出现负数
        self.update_attribute(type, [(self.send(type).to_f.send(value, amount.to_f)), 0.0].max)
      end
    end
  end

  #@@@@@@ 债权转让 @@@@@@@
  def can_be_sold?
    self.not_collected_amount - self.not_collected_interest >= MIN_SELL_AMOUNT
  end

  # 叫卖
  def hawk amount
    return if amount > self.not_collected_principal
    self.update_attributes( :for_sale_amount => amount,
                            :for_sale_time => Time.now,
                            :for_sale_month => self.collections.unpaid.count,
                            :for_sale => true)
  end

  # 还款后自动取消转让
  def cancel_hawk
    return if self.for_sale == false
    self.update_attributes( :for_sale_amount => nil,
                            :for_sale_time => nil,
                            :for_sale_month => nil,
                            :for_sale => false)
  end

  def self.bought_by current_user, from_bid, invest_amount
    self.transaction do
      if from_bid.for_sale?
        bid = self.create(:user => current_user,
                          :loan_id => from_bid.loan_id,
                          :invest_amount => invest_amount.to_f,
                          :invest_month => from_bid.collections.unpaid.count,
                          :interest => from_bid.interest,
                          :status => 'repaying',
                          :from_bid => from_bid)

        CashFlow.sell_bid current_user, from_bid, bid, invest_amount.to_f

        # 生成新债权的 还款
        Collection.generate_for_bid from_bid, bid, current_user

        # 调整原始债权的 还款
        Collection.update_unpaid from_bid, bid

        if (from_bid.for_sale_amount == bid.invest_amount)
          from_bid.sale_stop
        else
          from_bid.update_attributes(:for_sale_amount => from_bid.for_sale_amount - bid.invest_amount)
        end
        bid.update_cash
        from_bid.update_cash
        from_bid.update_attribute(:sold_amount, (from_bid.sold_amount.to_f + invest_amount))
      end
    end
  end

  def sale_stop
    self.update_attributes( :for_sale => false,
                            :for_sale_amount => nil,
                            :for_sale_time => nil,
                            :for_sale_month => nil)
  end
  #@@@@@@ 债权转让结束 @@@@@@@

end
