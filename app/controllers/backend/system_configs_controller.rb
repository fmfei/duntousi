# encoding: utf-8
class Backend::SystemConfigsController < Backend::BaseController
  def index
    @search = SystemConfig.can_be_edit.order("id asc") #.search(params[:q])
    if params[:type].blank?
      @system_configs = @search.normal #.paginate :page => params[:page], :per_page => 20
      @title = '系统设置'
    elsif params[:type] == 'seo'
      @system_configs = @search.seo #.paginate :page => params[:page], :per_page => 20
      @title = '系统设置'
    elsif params[:type] == 'email_sms'
      @system_configs = @search.email_sms # .paginate :page => params[:page], :per_page => 20
      @title = '邮件设置'
    end
    @site_avaliable = FrontConfig.site_avaliable

  end

  def promotion
    @title = '邀请、注册奖励设置'
    @system_configs = SystemConfig.can_be_edit.promotion.order("id asc")
    @system_config = @system_configs.first
  end

  def update_promotion
    params["config"].each do |config|
      res = SystemConfig.find_by_key config
      res.update_attribute(:value, config[1])
    end
    redirect_to promotion_backend_system_configs_path
  end

  def prize
    @title = '投标奖励设置'
    @system_configs = SystemConfig.can_be_edit.prize.order("id asc")
    @system_config = @system_configs.first
  end

  def update_prize
    params["config"].each do |config|
      res = SystemConfig.find_by_key config
      res.update_attribute(:value, config[1])
    end
    redirect_to prize_backend_system_configs_path
  end


  def edit
    @system_config = SystemConfig.can_be_edit.find(params[:id])
    @title = '修改参数'
  end

  def update
    @system_config = SystemConfig.can_be_edit.find(params[:id])
    @system_config.changer_id = current_user.id

    respond_to do |format|
      if @system_config.update_attributes(system_configs_params)
        format.html { redirect_to backend_system_configs_path, notice: '更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @system_config.errors, status: :unprocessable_entity }
      end
    end
  end

  def site_avaliable
    @site_avaliable = FrontConfig.site_avaliable
  end

  def close_site
    case params[:status]
    when "true"
      params[:status] = true
    when "false"
      params[:status] = false
    end
    if status.present? and FrontConfig.save_site_status params[:status]
      render text: "修改成功"
    else
      render text: "修改失败"
    end
  end
  private 
    def system_configs_params
      params.require(:system_config).permit(:value)
    end

end