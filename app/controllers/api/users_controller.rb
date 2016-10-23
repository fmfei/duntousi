# encoding: utf-8
class Api::UsersController < Api::BaseController

  before_action :authenticate_user!, :verify_lender


  ##
  #
  # 个人账户信息
  #
  # GET /api/users
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "total_amount": 0, # 账户总金额
  #         "available": 0, # 可用金额
  #         "not_collection_total": 0, # 待收总金额
  #         "freeze_amount": 0 # 提现冻结
  #     }
  #  }
  def index
    @data = {
      'total_amount': current_user.total_amount.to_f.round(2),
      'available': current_user.show_available,
      'not_collection_total': current_user.not_collection_total.to_f.round(2),
      'freeze_amount': current_user.freeze_amount.to_f.round(2)
    }
    render 'layouts/api', layout: false
  end


end