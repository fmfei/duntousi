class OfflineBank < ActiveRecord::Base
	belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
	has_many :offline_recharges
	validates :name, presence: true
	validates :detail, presence: true

	STATUS = {'显示' => 'on', '不显示' => 'off'}

	scope :on, -> {where(:status => 'on')}
end
