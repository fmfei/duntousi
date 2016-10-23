# coding: utf-8
module ApplicationHelper
  def loan_state loan
    case loan.loan_state_id
    when Dict::LoanState.bidding.id
      '投标'
    when Dict::LoanState.failed.id
      '流标'
    when Dict::LoanState.bids_auditing.id
      '复审中'
    when Dict::LoanState.repaying.id
      '还款中'
    when Dict::LoanState.overdue.id
      '逾期'
    when Dict::LoanState.finished.id
      '完成'
    else
      "预计发标时间: #{format_time(loan.estimated_time,false,true)}" if loan.state == Dict::LoanState.wait_to_bid and loan.estimated_time.present?
    end
  end

  def rmb amount, with_yuan=true
    amount = [amount.to_f, 0.0].max
    if with_yuan
      format("%.2f", amount.to_f) + '￥'
    else
      format("%.2f", amount.to_f)
    end
  end

  def rmb_wan amount
    amount = [amount.to_f, 0.0].max
    format("%.2f", (amount.to_f/10000)) + '万'
  end

  #投标金额显示  低于100万用数字显示
  def bid_amount amount
    amount = [amount.to_f, 0.0].max.to_i
    if amount < 1000000
      amount.to_s
    else
      (amount/10000).to_s + '万'
    end
  end

  def percent amount
    format("%.2f", amount.to_f)
  end

  def avatar height='', class_name = ''
    unless current_user.info.avatar_url.nil?
      image_tag current_user.info.avatar.url, :class=>"img-responsive #{class_name}", :style=>"height:#{height}px;"
    else
      image_tag asset_url("account/xtouxiang.jpg"), :class=>"img-responsive #{class_name}", :height=>"#{height}"
    end
  end

  def must_be_login
    "<div class='contrast-blue box'>
      <div class='box-content text-center'>
        <h3>请 <a href='/users/sign_in ' class: 'text-contrast'>登录</a> 或 <a href='/sign_up ' class: 'text-contrast'>注册</a> 后查看</h3>
      </div>
    </div>".html_safe
  end

  def keep_mysterious_rule(str, type = 'other', start_at = 1, length = nil)
    return '' if str.blank?
    case type
    when 'name'
      start_at = 1
      length = str.length
    when 'phone'
      start_at = 3
      length = 9
    when 'id_card'
      start_at = 3
      length = str.length == 15 ? 8 : 11
    else
      length = str.length if length.nil?
    end

    str_match = str[start_at, start_at.to_i + length.to_i]
    str_match.blank? ? str : str.sub(str_match, '*'*length)
  end

  def keep_mysterious(str, start_at, length)
    keep_mysterious_rule(str, type = 'other', start_at = 1, length = nil)
  end

  def keep_mysterious_sp(str, type)
    keep_mysterious_rule(str, type)
  end

  def bank_card number
    return ' ' if number.blank?
    '************' + number[-4..-1].to_s
  end

  def format_time time, with_minutes=true, slash=false
    return '' if time.blank?
    if slash
      return time.strftime("%Y/%m/%d")
    end
    if with_minutes
      time.strftime("%Y-%m-%d %H:%M:%S")
    else
      time.strftime("%Y-%m-%d")
    end
  end

  def format_bonu bonu
    return '' if bonu.blank?
    if bonu == 'cash'
      return "现金"
    elsif bonu == 'actual_object'
      return "实物"
    elsif bonu == 'bribery_money'
      return "红包"
    else
      return "未知"
    end
  end

  def bid_avatar_url loan
    if loan
      url = loan.try(:avatar_url)
    else
      url = loan.borrower.try(:info).try(:avatar_url)
    end
    url.nil? ? asset_url('account.gif') : url
  end

  def invest_path loan
    if loan.is_a? Loan
      "/show_invest?id=#{loan.id}"
    else
      "/show_invest?id=#{loan}"
    end
  end
end
