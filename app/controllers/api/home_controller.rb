class Api::HomeController < Api::BaseController

  skip_before_action :ajax_requests_required

  ##
  #
  # 最新的标
  #
  def index
    @loan = Loan.bidding_or_after.order('available_amount desc, id desc').where("pass = ''").first
    @info = {
      id: @loan.id,
      invest_amount: (Loan.total_amount + 95366700).to_i,
      interest_amount: (Collection.sum(:interest) + 1999200).to_i,
      process: @loan.progress,
      interest: @loan.interest,
      months: @loan.months,
      available_amount: @loan.available_amount,
      title: @loan.title[0, 15]
    }


    # render 'layouts/api', layout: false
  end

end