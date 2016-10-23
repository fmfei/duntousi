# encoding: utf-8
class Account::BaseController < ApplicationController

  before_action :authenticate_user!, :verify_lender

  layout 'account'

  private
  def verify_lender
    redirect_to root_url unless current_user.roles.is_lender.present?
  end

end