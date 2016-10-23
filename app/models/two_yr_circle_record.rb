# coding: utf-8
class TwoYrCircleRecord < ActiveRecord::Base
  belongs_to :user

  scope :actived, ->{where('actived_at is not null')}
  scope :not_actived, ->{where('actived_at is null')}
  scope :today, ->{where(["date(actived_at) = ?", Date.today])}
  scope :today_create, ->{where(["date(created_at) = ?", Date.today])}
  scope :used, ->{where('is_used = true')}
  scope :unused, ->{where('is_used is null')}

  def self.create_for user
    self.transaction do
      r = rand(1..19)
      pri = 1
      if r == 19
        pri = 3
      elsif r > 12
        pri = 2
      end
      TwoYrCircleRecord.create(:user_id => user.id,
                               :prize => pri.to_s)
    end
  end

  def angle
    case prize
    when '1'
      arr = [23, 113, 203, 293]
      arr[rand(4)] + rand(5..37)
    when '2'
      arr = [0, 68, 158]
      temp = arr[rand(3)]
      if temp == 0
        temp + rand(4..17)
      else
        temp + rand(5..37)
      end 
    when '3'
      248 + rand(5..37)
    end
  end

  def prize_text
    case prize
    when '1'
      '10元红包'
    when '2'
      '50元红包'
    when '3'
      '200元红包'
    end
  end

  def prize_amount
    case prize
    when '1'
      10
    when '2'
      50
    when '3'
      200
    end
  end

end
