# coding: utf-8
class ZhongqiuRecord < ActiveRecord::Base
  belongs_to :user

  scope :process, ->{where(:status => 'process')}
  scope :finish, ->{where(:status => 'finish')}
  scope :fail, ->{where(:status => 'fail')}

  def ZhongqiuRecord.create_for(current_user, level)
    if current_user.zhongqiu_records.process.count == 0
      self.create(:user => current_user,
                  :start_at => DateTime.now,
                  :status => 'process',
                  :level => level)
      '任务已领取'
    else
      "同一时间只能领取一个任务，您已领取任务#{current_user.zhongqiu_records.process.first.level}"
    end
  end

  def ZhongqiuRecord.finish_for(current_user, level)
    if current_user.zhongqiu_records.process.where(:level => level).count > 0
      record = current_user.zhongqiu_records.process.where(:level => level).first
      invest_amount = current_user.bids.manual.where("created_at > ? and created_at < ?", record.start_at, DateTime.now).sum(:invest_amount)
      case level
      when '1'
        if invest_amount >= 5000
          record.update_attributes(:end_at => DateTime.now,
                                   :invest_amount => invest_amount,
                                   :prize => 20,
                                   :status => 'finish')
          CashFlow.prize(current_user, 20)
          '任务已完成，奖励20元'
        else
          "您已投资#{invest_amount.to_f.round(2)}元，还需投资#{5000 - invest_amount.to_f.round(2)}元才能完成此任务"
        end
      when '2'
        if invest_amount >= 20000
          record.update_attributes(:end_at => DateTime.now,
                                   :invest_amount => invest_amount,
                                   :prize => 60,
                                   :status => 'finish')
          CashFlow.prize(current_user, 60)
          '任务已完成，奖励60元'
        else
          "您已投资#{invest_amount.to_f.round(2)}元，还需投资#{20000 - invest_amount.to_f.round(2)}元才能完成此任务"
        end
      when '3'
        if invest_amount >= 50000
          record.update_attributes(:end_at => DateTime.now,
                                   :invest_amount => invest_amount,
                                   :prize => 150,
                                   :status => 'finish')
          CashFlow.prize(current_user, 150)
          '任务已完成，奖励150元'
        else
          "您已投资#{invest_amount.to_f.round(2)}元，还需投资#{50000 - invest_amount.to_f.round(2)}元才能完成此任务"
        end
      when '4'
        if invest_amount >= 80000
          record.update_attributes(:end_at => DateTime.now,
                                   :invest_amount => invest_amount,
                                   :prize => 320,
                                   :status => 'finish')
          CashFlow.prize(current_user, 320)
          '任务已完成，奖励320元'
        else
          "您已投资#{invest_amount.to_f.round(2)}元，还需投资#{80000 - invest_amount.to_f.round(2)}元才能完成此任务"
        end
      end

    else
      '任务已完成'
    end
  end

  def ZhongqiuRecord.fail_for(current_user, level)
    if current_user.zhongqiu_records.process.where(:level => level).count > 0
      record = current_user.zhongqiu_records.process.where(:level => level).first
      invest_amount = current_user.bids.manual.where("created_at > ? and created_at < ?", record.start_at, DateTime.now).sum(:invest_amount)
      record.update_attributes(:end_at => DateTime.now,
                               :invest_amount => invest_amount,
                               :status => 'fail')
      '任务已放弃，可以领取其他任务'
    else
      '未领取此任务'
    end
  end

  def status_text
    case self.status
    when 'process'
      '进行中'
    when 'finish'
      '已完成'
    when 'fail'
      '已放弃'
    end
  end

end