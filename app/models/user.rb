# coding: utf-8
class User < ActiveRecord::Base
  rolify
  acts_as_token_authenticatable # 允许token验证

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :async, :authentication_keys => [:login]

  # validates :username, :presence => true, :uniqueness => {:message=>"用户名已存在"}, :format => {:with=>/.{2,16}/i, :message=>"2-16个字符"}
  validates :mobile, :presence => true, :uniqueness => {:message=>"号码已存在"}
  # validates :email, :uniqueness => {:message => '此邮箱已注册'}
  attr_accessor :login

  #has_and_belongs_to_many :roles, :join_table => 'users_roles'
  has_many :permissions, :through => :roles
  has_one :info, :class_name => "UserInfo"
  accepts_nested_attributes_for :info
  has_many :articles
  has_many :loans
  has_many :pay_orders
  has_one :user_cash
  has_many :withdraws
  has_many :user_banks
  has_many :repayments
  has_many :bids
  has_many :rookie_bids
  has_many :collections
  has_many :auto_invest_rules
  has_many :contacts
  has_many :received_messages, :class_name => "Message", :foreign_key => "receive_user_id"
  has_many :sent_messages, :class_name => "Message", :foreign_key => "send_user_id"
  belongs_to :from_user,:class_name=>"User",:foreign_key => "from_user_id"
  has_many :invite_users,:class_name=>"User",:foreign_key => "from_user_id"
  has_many :offline_recharges

  has_many :identifications
  accepts_nested_attributes_for :identifications

  has_many :circle_records
  has_one :circle_chance
  has_many :egg_records
  has_many :zhongqiu_records
  has_many :lucky_codes
  has_many :lucky_guesses
  has_many :huodong_comments
  has_many :newyear_eggs
  has_many :product_orders
  has_many :coupons
  has_many :two_yr_circle_records
  has_many :bonus

  default_scope { order("id asc") }
  # scope :simple_search, lambda{|key_word| where("email like '%#{key_word}%' or username like '%#{key_word}%' or id in(select user_id from user_infos where name like '%#{key_word}%' or phone like '%#{key_word}%' or mobile like '%#{key_word}%')")  }
  scope :simple_search, lambda{|key_word| where("email like '%#{key_word}%' or mobile like '%#{key_word}%' or id in(select user_id from user_infos where name like '%#{key_word}%' or phone like '%#{key_word}%')")  }
  scope :auth_mobile_pass, lambda{|status=nil| where(:auth_mobile => ((status.nil? || status==true) ? true : false))}
  scope :auth_realname_pass, -> {where(:auth_realname => 1)}
  scope :auth_realname_reject, -> {where(:auth_realname => 0)}
  scope :auth_realname_ready, -> {where(:auth_realname => 2)}
  scope :auth_realname_notready, -> {where(:auth_realname => nil)}
  scope :of_role, ->(role) { joins(:roles).where("roles.name = ?", role) }
  scope :lender, -> {joins(:roles).where("roles.name = ?", '投资人')}
  scope :borrower, -> {joins(:roles).where("roles.name = ?", '贷款人')}

  scope :auth_email_pass, -> {where('confirmed_at is not null')}

  UserCash::TYPES.values.each do |type|
    {'add' => '+', 'minus' => '-'}.each do |key, value|
      delegate "#{key}_#{type}", to: :user_cash
    end
  end

  UserCash::TYPES.values.each do |cash|
    delegate cash, to: :user_cash
  end

  after_create :create_user_cash, :create_user_info

  def create_user_cash
    UserCash.create({:user => self})
  end

  def create_user_info
    info = UserInfo.new({:user => self})
    info.save(:validate => false)
  end

  def gender
    if self.info.id_card.blank?
      ''
    elsif self.info.id_card.at(-2).to_i.odd?
      '男'
    else
      '女'
    end
  end

  # 账户总额 = 充值总额 + 红包 - 后台扣款 + 已收利息 + 未收利息 - 提现总额
  # 账户总额 = 可用金额 + 待收总额 + 提现冻结 + 投标中的金额
  def total_amount
    (self.available.to_f + self.not_collection_total.to_f + self.freeze_amount.to_f + self.bids.bidding.sum(:invest_amount).to_f).round(2)
    # self.total.to_f
  end

  def show_available
    if self.available.to_f.round(2) > 0
      (self.available.to_f.to_s.split('.')[0] + '.'+ self.available.to_f.to_s.split('.')[1][0...2]).to_f
    else
      '0.0'
    end
  end

  def correct_cash
    self.user_cash.available = [remaining_balance, 0.0].max
    self.user_cash.collected_interest = self.collections.paid.sum(:interest).to_f.round(2)
    self.user_cash.not_collection_total = self.collections.unpaid.sum(:amount).to_f.round(2)
    self.user_cash.not_collection_principal = self.collections.unpaid.sum(:principal).to_f.round(2)
    self.user_cash.not_collection_interest = self.collections.unpaid.sum(:interest).to_f.round(2)
    self.user_cash.total = self.total_amount
    self.user_cash.save
  end

  #
  def remaining_balance(cash_flow=nil)
    if (cash_flow.nil?)
      # 收入之和 - 支出支出
      (CashFlow.where(to_user_id: self.id).sum(:amount) - CashFlow.where(from_user_id: self.id).sum(:amount)).to_f.round(2)
    else # 计算某条cash_flow之前的余额，例如：出借人-》我的流水-》可支配余额
      (CashFlow.where(["to_user_id=? and id<=? ",self.id,cash_flow.id]).sum(:amount)-CashFlow.where(["from_user_id=? and id<=? ",self.id,cash_flow.id]).sum(:amount)).to_f
    end
  end

  # 免费提现额 = 15天外充值金额 + 已赚利息 - 提现金额 - 正在提现中的金额.
  def free_withdraw_amount
    [(CashFlow.recharged_for(self.id).sum(:amount).to_f + self.collected_interest.to_f - withdraw_total.to_f - self.withdraws.auditing.sum(:amount)), 0].max
  end

  def username
    name.present? ? name : (self.mobile || self.email)
  end

  def name
    if self.id > 0
      name = self.try(:info).try(:name).to_s
    else
      case self.id
      when User.company.id
        '公司账户'
      when User.agent.id
        '公司托管账户'
      when User.asset.id
        '投资人委托账户'
      when User.input_fee.id
        '汇入手续费'
      when User.output_fee.id
        '提现手续费'
      end
    end
  end

  def name_or_email
    if self.id > 0
      name = self.try(:info).try(:name).to_s
      if name.blank?
        self.email
      else
        name
      end
    else
      case self.id
      when User.company.id
        '公司账户'
      when User.agent.id
        '公司托管账户'
      when User.asset.id
        '投资人委托账户'
      when User.input_fee.id
        '汇入手续费'
      when User.output_fee.id
        '提现手续费'
      end
    end
  end

  def is_admin?
    roles.map(&:is_admin).include? true
  end

  def has_role? role
    self.roles.map(&:name).include? role
  end

  def self.company
    self.find_by_id(0)
  end

  # Risk fund account, to store risk fund
  def self.risk_fund
    self.find_by_id(-1)
  end

  # Agent account, to store money for bid, repayment, etc
  def self.agent
    self.find_by_id(-2)
  end

  def self.asset
    self.find_by_id(-3)
  end

  def self.input_fee
    self.find_by_id(-101)
  end

  def self.output_fee
    self.find_by_id(-102)
  end

  def cash_flows
    CashFlow.with_user(self.id)
  end

  def check_auth_realname
    if (info.id_card.present? && name.present? && info.idcard_pic_url.present?)
      self.update_attribute(:auth_realname, 2)
    else
      self.update_attribute(:auth_realname, nil)
    end
  end

  def auth_realname_state
    case auth_realname
    when nil
      "信息不全"
    when 0
      "认证错误"
    when 1
      "已认证"
    when 2
      "待审核"
    end
  end

  def auth_realname_pass pass
    self.auth_realname = pass
    if self.save
      {code: 1, data: "修改成功"}
    else
      {code: 0, data: "修改失败"}
    end
  end

  def pass_auth_mobile
    self.update_attribute(:auth_mobile, true)
  end

  # 提现密码
  def trade_password
    begin
      @trade_password ||= BCrypt::Password.new(encrypted_trade_password)
    rescue
      ''
    end
  end

  def trade_password=(new_password)
    @password = BCrypt::Password.create(new_password)
    self.encrypted_trade_password = @password
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(mobile) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.find_by_login(login)
    # self.find_by_email(login) or self.find_by_username(login)
    self.find_by_mobile(login) or self.find_by_email(login)
  end

  def email_required?
    return false
  end

  # 奖励收入总额
  def prize_total
    (CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.promote_prize.id}).sum(:amount).to_f +
    CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.prize_first.id}).sum(:amount).to_f +
    CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.prize_max.id}).sum(:amount).to_f +
    CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.prize_last.id}).sum(:amount).to_f +
    CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.prize_register.id}).sum(:amount).to_f +
    CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.prize.id}).sum(:amount).to_f +
    CashFlow.where({:to_user => self, :cash_flow_description_id => Dict::CashFlowDescription.prize_offline.id}).sum(:amount).to_f).round(2)
  end

  # 提现手续费
  def withdraw_fee_total
    self.withdraws.succeed.sum(:fee).to_f.round(2)
  end

  # 债权转让手续费
  def sell_bid_fee_total
    CashFlow.where({:from_user => self, :cash_flow_description_id => Dict::CashFlowDescription.sell_bid_fee.id}).sum(:amount).to_f.round(2)
  end

  # 投标中的金额
  def bidding_total
    self.bids.status_in(['bidding', 'bids_auditing']).sum(:invest_amount).round(2)
  end

  protected
    def confirmation_required?
      false
    end
end
