class Api::BaseController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token, if: lambda { |controller| controller.request.format.json? }

  # disable cookies (no set-cookies header in response)
  # before_action :destroy_session

  layout 'api.json.jbuilder'

  def destroy_session
    request.session_options[:skip] = true
  end

  private
  def verify_lender
    redirect_to root_url unless current_user.roles.is_lender.present?
  end

end