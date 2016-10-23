# coding: utf-8
class CircleRecord < ActiveRecord::Base
  belongs_to :user

  scope :actived, ->{where('actived_at is not null')}
  scope :not_actived, ->{where('actived_at is null')}
  scope :today, ->{where(["date(actived_at) = ?", Date.today])}

  def self.create_for user
    self.transaction do
      if user.circle_records(true).count < 3
      	CircleRecord.create(:user_id => user.id,
                            :prize => '1')
      elsif user.circle_records(true).count >= 3 && user.circle_records(true).count < 5 && (user.circle_records.where(:prize => '2').count == 0)
        CircleRecord.create(:user_id => user.id,
                            :prize => '2')
      elsif user.circle_records(true).count >= 5 && user.circle_records(true).count < 10 && (user.circle_records.where(:prize => '3').count == 0)
        CircleRecord.create(:user_id => user.id,
                            :prize => '3')
      elsif user.circle_records(true).count >= 10 && user.circle_records(true).count < 15 && (user.circle_records.where(:prize => '4').count == 0)
        CircleRecord.create(:user_id => user.id,
                            :prize => '4')
      else
        CircleRecord.create(:user_id => user.id,
                            :prize => '1')
      end
    end
  end

  def angle
  	case prize
  	when '1'
  		310 + rand(25)
  	when '2'
  		18 + rand(36)
    when '3'
      280 + rand(25)
    when '4'
      205 + rand(20)
    when '6'
      95 + rand(20)
    when '7'
      244 + rand(20)
  	end
  end

  def prize_text
    case prize
    when '1'
      '20元话费'
    when '2'
      '50元话费'
    when '3'
      '100元话费'
    when '4'
      '300元现金'
    when '5'
      '金元宝20g'
    when '6'
      '金条10g'
    when '7'
      '金羊一只'
    when '8'
      '一帆风顺'
    end
  end

end
