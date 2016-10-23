module Backend::BannersHelper
  def show_result_info(result)
    if result == "win"
      "中奖"
    elsif result == "not_win"
      "未中奖"
    else
      "未开奖"
    end
  end
end
