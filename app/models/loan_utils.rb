# -*- coding: utf-8 -*-
class LoanUtils
  class << self
    # 试算 用的年化利率
    def max_interest
      0.15
    end

    # 平台费占出借总金的比例
    def platform_fee
      0.05
    end

    def max_amount
      50000
    end

    # 每期还款金额(包含平台费)
    # @param [BigDecimal] 本金
    # @param  [Fixnum] 期数
    # @param [BigDecimal] 年化利率
    # @return [BigDecimal]
    def calc_payback(amount, months, interest = self.max_interest)
      return if amount <= 0 or months <= 0 or interest < 0
      interest /= 12
      ((amount * interest / (1.0 - 1.0 / (1 + interest) ** months)) + (amount * platform_fee)/months).round(2)
    end

    # 先付利息产品时，每月需要还的利息
    def calc_payback_interest_only(amount, borrower)
      (amount * BigDecimal.new(borrower.contract.interest.to_s) / 1200.0).to_f.round(2)
    end

    # PMT函数即年金函数。PMT基于固定利率及等额分期付款方式，返回贷款的每期付款额 (不包含平台费)
    # @param [BigDecimal] 月利率
    # @param [Fixnum] 期数
    # @param [BigDecimal] 本金
    def pmt(rate, months, amount)
      amount * rate / (1 - (1 + rate) ** (-months))
    end

    # 求本金
    def ss(pmt, months, rate)
      pmt * (1 - (1 + rate) ** (-months)) / rate
    end

    # 计算 分期
    # e.g. 10k 12月 年化12.24% : LoanUtils.equal_repayments_table(10000, 12, 12.24/12)
    def equal_repayments_table(amount, month, month_rate)
      amount = amount.to_f
      month = month.to_i
      month_rate = month_rate.to_f
      monthly_payment = pmt(BigDecimal.new(month_rate.to_s)/100.0, month.to_i, amount.to_f)

      seed_interst = {}

      1.upto(month) do |month_index|
        interest_amount = amount * BigDecimal.new(month_rate.to_s) / 100.0
        seed = monthly_payment - interest_amount
        amount -= seed
        seed_interst[month_index] = {:seed => seed.round(2), :interest => interest_amount.round(2), :left_seed => amount.round(2).abs}
      end

      seed_interst
    end

    # 先付利息 分期表
    def interest_only_table(amount, month, year_rate)
      amount = amount.to_f
      month = month.to_i
      year_rate = year_rate.to_f
      monthly_interest = (amount * BigDecimal.new(year_rate.to_s)).to_f / 1200.0
      table = {}
      1.upto(month-1) do |month_index|
        table[month_index] = {:seed => 0.0, :interest => monthly_interest.to_f.round(17), :left_seed => amount.round(2)}
      end
      table[month] = {:seed => amount.to_f.round(17), :interest => monthly_interest.to_f.round(17), :left_seed => 0.0}
      table
    end

    # 到期付本息 分期表
    def repay_at_due_table(amount, month, year_rate)
      amount = amount.to_f
      month = month.to_i
      year_rate = year_rate.to_f
      {
        :seed => amount,
        :interest => amount * year_rate * month / 1200.00
      }
    end
  end

end
