# coding: utf-8
class UserCash < ActiveRecord::Base
  # attr_accessible :user, :available, :collected_interest, :freeze_amount,
  #                 :invest_total, :loan_total, :not_collection_interest,
  #                 :not_collection_total, :not_repay_total, :total, :user_id,
  #                 :withdraw_fee, :withdraw_received, :withdraw_total
  belongs_to :user

  validates :user_id, presence:true, uniqueness: true
  validates :available, :collected_interest, :freeze_amount,
            :invest_total, :loan_total, :not_collection_interest,
            :not_collection_total, :not_repay_total, :total, :user_id,
            :withdraw_fee, :withdraw_received, :withdraw_total,
            :allow_nil => true, :numericality => {:greater_than_or_equal_to => 0}

  TYPES = { '账户总金额' => 'total',
            '可用金额' => 'available',
            '冻结金额' => 'freeze_amount',
            '投资总额' => 'invest_total',
            '已收利息' => 'collected_interest',
            '待收总额' => 'not_collection_total',
            '待收本金' => 'not_collection_principal',
            '待收利息' => 'not_collection_interest',
            '贷款总额' => 'loan_total',
            '未还总额' => 'not_repay_total',
            '提现手续费' => 'withdraw_fee',
            '提现到账金额' => 'withdraw_received',
            '提现总额' => 'withdraw_total',
            '充值总额' => 'recharge_total',
            '已免费提现金额' => 'free_withdrew',
            '新手体验金' => 'rookie_amount'}

  # 定义更新属性的方法
  # 例如，账户总金额 + 12，方法为：user.user_cash.minus_total 12
  # 账户总金额 - 12：user.user_cash.minus_total 12
  TYPES.values.each do |type|
    {'add' => '+', 'minus' => '-'}.each do |key, value|
      # 例如： add_total
      define_method "#{key}_#{type}" do |amount|
        # 防止出现负数
        self.update_attribute(type, [(self.send(type).to_f.send(value, amount.to_f)), 0.0].max)
      end
    end
  end

end