# coding: utf-8
class EggRecord < ActiveRecord::Base
  belongs_to :user

  def self.create_for current_user, egg
    case egg
    when 'egg1'
      if current_user.created_at >= Date.new(2015, 9, 6) && current_user.auth_realname?
        if current_user.egg_records.where(level: '1').count() == 0
          self.create(user: current_user, level: '1', prize: '50元红包')
          CashFlow.prize(current_user, 50)
          '50元红包(投资2000元可提现)'
        else
          '每个新手只有一个彩蛋'
        end
      else
        '彩蛋属于"活动期间新注册，并且实名认证的用户"'
      end
    when 'egg2'
      if self.invest_today(current_user) >= 5000 && current_user.egg_records.where("created_at >= ? and created_at <= ?", Date.today, Date.tomorrow).count() == 0
        self.create(user: current_user, level: '2', prize: '50元红包')
        CashFlow.prize(current_user, 50)
        '50元红包'
      else
        '投资5000元可砸此蛋，每天只有一次砸蛋机会'
      end
    when 'egg3'
      if self.invest_today(current_user) >= 10000 && current_user.egg_records.where("created_at >= ? and created_at <= ?", Date.today, Date.tomorrow).count() == 0
        if self.count % 3 == 0
          self.create(user: current_user, level: '3', prize: '100元红包')
          CashFlow.prize(current_user, 100)
          '100元红包'
        else
          self.create(user: current_user, level: '3', prize: '小米手环')
          '小米手环'
        end
      else
        '投资10000元可砸此蛋，每天只有一次砸蛋机会'
      end
    when 'egg4'
      if self.invest_today(current_user) >= 50000 && current_user.egg_records.where("created_at >= ? and created_at <= ?", Date.today, Date.tomorrow).count() == 0
        if self.count % 3 == 0
          self.create(user: current_user, level: '4', prize: '200元红包')
          CashFlow.prize(current_user, 200)
          '200元红包'
        else
          self.create(user: current_user, level: '4', prize: '移动电源')
          '移动电源'
        end
      else
        '投资50000元可砸此蛋，每天只有一次砸蛋机会'
      end
    when 'egg5'
      if self.invest_today(current_user) >= 100000 && current_user.egg_records.where("created_at >= ? and created_at <= ?", Date.today, Date.tomorrow).count() == 0
        if self.count % 3 == 0
          self.create(user: current_user, level: '5', prize: '拍立得')
          '拍立得'
        else
          self.create(user: current_user, level: '5', prize: '500元红包')
          CashFlow.prize(current_user, 500)
          '500元红包'
        end
      else
        '投资100000元可砸此蛋，每天只有一次砸蛋机会'
      end
    end
  end

  def self.invest_amount user
    user.bids.where("created_at >= ? and created_at <= ?", Date.new(2015, 9, 6), Date.new(2015, 9, 12)).sum(:invest_amount).to_f.round(2)
  end

  def self.invest_today user
    user.bids.where("created_at >= ? and created_at <= ?", Date.today, Date.tomorrow).sum(:invest_amount).to_f.round(2)
  end

  def egg
    case self.level
    when '1'
      '彩蛋'
    when '2'
      '铜蛋'
    when '3'
      '银蛋'
    when '4'
      '金蛋'
    when '5'
      '钻石蛋'
    end
  end

end
