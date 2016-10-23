class Message < ActiveRecord::Base
  # attr_accessible :content, :deleted, :receive_user_id, :reply, :replytime, :send_user_id, :status, :title, :type
  belongs_to :receive_user, :class_name => "User"
  belongs_to :send_user, :class_name => "User"
  validates :receive_user_id, presence: true
  validates :title, presence: true
  validates :content, presence: true 

  scope :read, -> {where(:status => Dict::MessageStatus.read.id)}
  scope :unread, -> {where(:status => Dict::MessageStatus.unread.id)}

  def set_read
    self.update_attributes(:status =>Dict::MessageStatus.read.id)
  end

  def set_unread
    self.update_attributes(:status =>Dict::MessageStatus.unread.id)
  end
  
  def self.set_read
    self.update_all(:status =>Dict::MessageStatus.read.id)
  end

  def self.set_unread
    self.update_all(:status =>Dict::MessageStatus.unread.id)
  end

  def read?
    self.status == Dict::MessageStatus.read.id
  end

  def unread?
    self.status == Dict::MessageStatus.unread.id
  end
end
