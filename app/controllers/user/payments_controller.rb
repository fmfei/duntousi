# -*- coding: utf-8 -*-
class User::PaymentsController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :authenticate_user!, :only => :finish
  skip_before_filter :verify_authenticity_token, :only => :finish

  def finish
    @order = PayOrder.find_by_uuid(params[:id])
    if (ThirdPay.verify_response(params) or (!Utils.production?))
      PayOrder.transaction do
        @order.update_attribute(:pay_class,params[:pay_class].titleize)
        unless @order.success
          @order.finish(ThirdPay.order_id(params), ThirdPay.out_order_id(params))
        end
      end

      if ThirdPay.notice_from(params) == 2
        render ThirdPay.notice_succ_response(params)
      else
        flash[:success] = '充值成功'
        redirect_to account_recharge_path
        return
      end
    else
      render :nothing => true
    end
  end

end
