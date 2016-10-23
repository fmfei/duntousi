# coding: utf-8
class SystemConfig < ActiveRecord::Base
  translate_key
  # attr_accessible :changer_id, :description, :key, :value, :editable
  validates :key, uniqueness: true
  NORMAL = %w{company_name auto_invest_at sell_bid_fee phone400 serve_time qq_server qq_group}
  SEO = %w{title keywords description}
  EMAIL_SMS = %w{email_name email_pass sms_name sms_pass}
  PROMOTION = %w{promotion_status promotion_type promotion_amount promotion_ratio promotion_threshold prize_register_status prize_register_amount}
  PRIZE = %w{prize_first_status prize_first_threshold prize_first_amount prize_max_status prize_max_amount prize_last_status prize_last_amount}

  belongs_to :changer, :class_name => 'User'
  
  scope :can_be_edit, -> {where(:editable => true)}
  scope :can_not_be_edit,-> { where(:editable => false)}
  scope :normal, -> {where(["key in (?)", SystemConfig::NORMAL])}
  scope :seo, -> {where(["key in (?)", SystemConfig::SEO])}
  scope :email_sms, -> {where(["key in (?)", SystemConfig::EMAIL_SMS])}
  scope :promotion, -> { where(["key in (?)", SystemConfig::PROMOTION]) }
  scope :prize, -> { where(["key in (?)", SystemConfig::PRIZE]) }


  class << self
    %w{ company_name email_name email_pass sms_name sms_pass auto_invest_at mongodb_logger_pass title keywords description sell_bid_fee promotion_status promotion_type promotion_amount promotion_ratio promotion_threshold prize_first_status prize_first_threshold prize_first_amount prize_max_status prize_max_amount prize_last_status prize_last_amount prize_register_status prize_register_amount
        phone400 serve_time qq_server qq_group}.each do |key|
      define_method key do
        self.find_by_key(key)
      end
    end

    # 推荐奖励设置
    # promotion_status 是否启用  on/off
    # promotion_type 固定、比例  fixed/retio
    # promotion_threshold 奖励门槛
    # promotion_amount 固定奖励金额
    # promotion_ratio 奖励比例
    # 满标时奖励
    
    # 首投奖
    # prize_first_status 是否启用  on/off
    # prize_first_threshold 门槛
    # prize_first_amount 金额

    # 单标冠军奖
    # prize_max_status 是否启用  on/off
    # prize_max_amount 金额

    # 满标奖
    # prize_last_status 是否启用  on/off
    # prize_last_amount 金额

    # 注册奖励
    # prize_register_status 是否启用  on/off
    # prize_register_amount 金额

    define_method 'auto_invest_at' do
      self.find_by_key('auto_invest_at').try(:value).try(:to_datetime)
    end
  end
end
