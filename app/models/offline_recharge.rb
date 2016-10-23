class OfflineRecharge < ActiveRecord::Base
	belongs_to :user
	belongs_to :auditor, :class_name => 'User', :foreign_key => 'auditor_id'
	belongs_to :offline_bank
	validates :amount, presence: true

	STATUS = {'成功': 1, '失败': 0}

	scope :success, -> {where(:status => 1)}
	scope :fail, -> {where(:status => 0)}
	scope :need_audit, -> {where('status is null')}

	def succeed
		CashFlow.recharge_for self.user, self.permit_amount.to_f, nil, '', Dict::CashFlowDescription.offline_recharge, self
	end

	def status_name
		case self.status
		when 1
			'充值成功'
		when 0
			'充值失败'
		else
			'审核中'
		end
	end


end
