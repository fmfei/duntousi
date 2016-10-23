# coding: utf-8
class AutoInvestRule < ActiveRecord::Base
#  attr_accessible :actived_at, :amount, :credit_level, :max_interest, :max_months, :min_interest, :min_months, :remain_amount, :repay_style, :user_id, :with_guarantee, :with_mortgage

  belongs_to :user

  scope :active, -> {where('actived_at is not null')}
  # scope :match_loan, lambda {|loan| where(["amount < ? and min_interest <= ? and max_interest >= ? and min_months <= ? and max_months >= ? and (with_mortgage = ? or with_mortgage = 'false' or with_mortgage is null) and (with_guarantee = ? or with_guarantee = 'false' or with_guarantee is null) and (repay_style = ? or repay_style = '' or repay_style is null)",
  #                                       loan.available_amount, loan.interest, loan.interest, loan.months, loan.months, loan.with_mortgage, loan.with_guarantee, loan.repay_style]) }
  scope :match_loan, lambda {|loan| where(["min_interest <= ? and max_interest >= ? and min_months <= ? and max_months >= ? and (repay_style = ? or repay_style = '' or repay_style is null)",
                                          loan.interest, loan.interest, loan.months, loan.months, loan.repay_style]) }
  scope :actived_at_gt, -> {where(["actived_at > ?", SystemConfig.auto_invest_at])}
  scope :actived_at_lte, -> {where(["actived_at <= ?", SystemConfig.auto_invest_at])}
  scope :active_before, lambda {|rule| active.where("queue < ?", rule.queue)}

  LIMIT = 1 # 最多投标的百分之多少
  MAX_USER = 250 #最多自动投标人数

  before_save :increase_queue

  def increase_queue
    if self.actived_at_changed? && self.actived_at.present?
      self.queue = AutoInvestRule.max_queue + 1
    end
  end

  # 自动投标
  def self.exec_for loan_id
    loan = Loan.find loan_id

    if loan.available_amount.to_f > 0

      self.includes(:user).active.match_loan(loan).order('queue asc').each do |rule|

        if loan.reload.available_amount.to_f == 0
          break
        else
          if (rule.user.available.to_i > loan.min_invest.to_i && rule.amount.blank?)
            begin
              Bid.auto_invest_by_user rule.user, loan_id, [loan.amount * LIMIT, rule.user.available.to_i].min
              PromotionJob.newyear_egg({'user_id' => rule.user.id, 'invest_amount' => [loan.amount * LIMIT, rule.user.available.to_i].min})
              #两周年庆转盘抽奖
              if (Time.now.to_date >= DateTime.new(2016, 8, 15)) && (Time.now.to_date <= DateTime.new(2016, 8, 20))
                invest_amount_count = (rule.user.bids.today.sum(:invest_amount).to_i)/10000
                already_records = rule.user.two_yr_circle_records.today_create.count
                if invest_amount_count >= 3
                  (invest_amount_count - already_records).times do 
                    TwoYrCircleRecord.create_for(rule.user)
                  end
                end
              end
            rescue Exception => e
            end
            # 投完的用户排到队尾
            rule.update_attribute(:queue, self.max_queue+1)
          elsif (rule.user.available.to_f.round(2) >= (rule.amount.to_f + rule.remain_amount.to_f).round(2))
            begin
              Bid.auto_invest_by_user rule.user, loan_id, [rule.amount.to_i, loan.amount * LIMIT, rule.user.available.to_i].min
              PromotionJob.newyear_egg({'user_id' => rule.user.id, 'invest_amount' => [rule.amount.to_i, loan.amount * LIMIT, rule.user.available.to_i].min})
              #两周年庆转盘抽奖
              if (Time.now.to_date >= DateTime.new(2016, 8, 15)) && (Time.now.to_date <= DateTime.new(2016, 8, 20))
                invest_amount_count = (rule.user.bids.today.sum(:invest_amount).to_i)/10000
                already_records = rule.user.two_yr_circle_records.today_create.count
                if invest_amount_count >= 3
                  (invest_amount_count - already_records).times do 
                    TwoYrCircleRecord.create_for(rule.user)
                  end
                end
              end
            rescue Exception => e
            end
            # 投完的用户排到队尾
            rule.update_attribute(:queue, self.max_queue+1)
          end
        end

      end
    end
  end
  # def self.exec_for loan
  #   if loan.available_amount.to_f > 0
  #     loan.update_attribute(:auto_invested_at, Time.now)
  #     self.includes(:user).active.actived_at_gt.match_loan(loan).each do |rule|
  #       if rule.user.available.to_f > (rule.amount.to_f + rule.remain_amount.to_f)
  #         begin
  #           Bid.auto_invest_by_user rule.user, loan.id, [rule.amount, loan.amount * LIMIT].min
  #         rescue
  #         end
  #       end
  #       SystemConfig.find_by_key('auto_invest_at').update_attribute(:value, rule.actived_at)
  #       if loan.available_amount.to_f == 0
  #         exit
  #       end
  #     end
  #   end

  #   if loan.available_amount.to_f > 0
  #     self.includes(:user).active.actived_at_lte.match_loan(loan).each do |rule|
  #       if rule.user.available.to_f > (rule.amount.to_f + rule.remain_amount.to_f)
  #         begin
  #           Bid.auto_invest_by_user rule.user, loan.id, [rule.amount, loan.amount * LIMIT].min
  #         rescue
  #         end
  #       end
  #       SystemConfig.find_by_key('auto_invest_at').update_attribute(:value, rule.actived_at)
  #       if loan.available_amount.to_f == 0
  #         exit
  #       end
  #     end
  #   end

  # end

  def self.amount_before rule
    self.active_before(rule).sum(:amount)
  end

  def self.max_queue
    rule = AutoInvestRule.where('queue is not null').order('queue desc').first
    if rule.present?
      rule.queue.to_i
    else
      0
    end
  end

end
