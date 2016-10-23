class PayOrder < ActiveRecord::Base
  # attr_accessible :amount, :bank_order_id, :callback_model, :callback_model_id, :callback_model_method, :callback_model_name, :callback_path, :creator_id, :paid, :pay_class, :pay_method_id, :payment_serial, :success, :uuid

  belongs_to :user
  has_many :cash_flows

  belongs_to :pay_method, :class_name => "Dict::PayMethod"

  validates :amount, :numericality => true, :presence => {:message=>"请输入正确的充值金额"}, :format => {:with=>/.{1,9}/i, :message=>"请输入正确的充值金额"}

  scope :succeed, -> {where(:success => true)}

  before_create :set_uuid
  def set_uuid
    self.uuid = unique_uuid
  end

  def unique_uuid

    random = Utils.random_salt(6)
    PayOrder.find_by_uuid(random).blank? ? random : unique_uuid
    
  end

  def callback_model=(instance)
    self.callback_model_name = instance.class.name
    self.callback_model_id = instance.id
  end

  def self.total_amount
    PayOrder.succeed.sum(:amount)
  end

  def callback_model
    begin
      self.callback_model_name.constantize.find_by_id(self.callback_model_id)
    rescue Exception => e
      nil
    end
  end

  # params[Fixnum]
  # params[Fixnum]
  # params[true/false] 是否调用 回调方法,如果不调用回调方法，只是充值到账户;默认是:调用
  # params[true/false] 是否从第三方后台汇入;默认是:否
  def finish(payment_serial, bank_order_id,callback=true,import=false)
    PayOrder.transaction do
      self.lock!
      unless self.success
        self.update_attributes(:success => true, :payment_serial => payment_serial, :bank_order_id => bank_order_id)
        CashFlow.recharge_for self.user, self.amount, self, self.pay_class
        self.callback_model.try(self.callback_model_method) if callback
      end
    end
  end

end