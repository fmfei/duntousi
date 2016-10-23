# encoding: utf-8

class Backend::HomeController < Backend::BaseController

  def index
    if current_user.source.present? || current_user.channel.present?
      redirect_to branch_backend_lenders_path
    end
  end

end
