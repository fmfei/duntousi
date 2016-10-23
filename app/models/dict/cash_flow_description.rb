class Dict::CashFlowDescription < Dictionary
  translate_name
  FORSEARCH = %w{charge pay_bid repay deduct withdraw withdraw_return withdraw_apply return_pay_bid transfer_to_borrower offline_recharge backend_recharge sell_bid sell_bid_fee prize_first prize_max prize_last prize_register auto_pay_bid withdraw_fee withdraw_fee_return withdraw_cancelled prize_offline prize promote_prize yiyuangou}
  scope :can_be_search, -> {where(["name in (?)", FORSEARCH])}
  class << self

    %w{charge pay_bid repay platform risk_fee deduct withdraw withdraw_return withdraw_apply input_fee output_fee return_pay_bid transfer_to_borrower offline_recharge backend_recharge sell_bid sell_bid_fee promote_prize prize_first prize_max prize_last prize_register auto_pay_bid withdraw_fee withdraw_fee_return withdraw_cancelled prize_offline prize yiyuangou rookie_bid}.each do |t|

      define_method t do
        self.find_by_name(t)
      end
    end
  end
end