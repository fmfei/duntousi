# encoding: utf-8
class Backend::UsersController < Backend::BaseController
  def index
    @title = '借款人管理'
    @q = User.joins(:info).of_role('贷款人').ransack(params[:q])
    @users = @q.result.reorder('id desc').paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @title = '创建用户'
    @user=User.new
  end

  def create
    @title = "借款人个人信息"
    @pwd = "Bwr_2014p2p"
    begin
      @user = User.create!(user_params)
      @user.roles << Role.find_by_name('贷款人')
      @user_info = @user.info
      4.times do
        @contacts = Contact.create!(:user_id=>@user.id)
      end
    rescue => e
      flash[:errors] = "手机号/邮箱不可用，请更换手机号/邮箱重试！"
      @user = User.new
      render :new
    else
      flash[:info] = "用户创建成功"
      @step = 1
      render :user_info
    end
  end

  #修改头像
  def change_avatar
    @title = "修改用户头像"
    @user = User.find(params[:id])
    @user_info = @user.info
  end

  # def create_user_info
  #   @user = User.find(params[:user_id])
  #   @user.info.attributes = params[:user_info]
  #   @step = params[:step].to_i || 1
  #   if @user.info.save
  #     flash[:success] = "添加成功！"
  #     if @step < 4
  #       @step += 1
  #       render :user_info
  #     else
  #       redirect_to action: :index
  #     end
  #   else
  #     flash[:errors] = @user.info.errors
  #     render :user_info
  #   end
  # end

  def edit
    @title = "修改用户信息"
    @user = User.find(params[:id])
    @user_info = @user.info
    @step = params[:step].try(:to_i) || 1
    @contacts = @user.contacts
    render :user_info
  end

  def update
    @user = User.find(params[:user_id])
    @step = params[:step].to_i || 1
    if @step <5
      @user.info.attributes = user_info_params
      if @user.info.save(:validate => false)
        flash[:success] = "添加成功！"
        @step += 1
        if params[:user_info][:avatar].present?
          redirect_to action: :index
        else
          redirect_to edit_backend_user_path(@user,:step=>@step)
        end
      else
        flash[:errors] = @user.info.errors
        redirect_to edit_backend_user_path(@user,:step=>@step)
      end
    elsif @step == 5
      @user.contacts.each do |contact|
        contact.update_attributes(contact_params(contact.id))
      end
      redirect_to action: :index
    else
      redirect_to action: :index
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user and @user.destroy
      flash[:success] = "删除成功！"
    else
      flash[:errors] = "删除失败！"
    end
    redirect_to action: :index
  end

  private
    def user_params
      params[:user].merge!(password: @pwd)
      params.require(:user).permit(:username, :email, :password, :mobile)
    end

    def user_info_params
      params.require(:user_info).permit(:id_card, :name, :user, :user_id, :marriage_type_id, :child, :education_type_id, :degree_type_id, :province, :city, :area, :detailed_address, :postcode, :phone, :mobile, :company_name, :company_type, :company_industry, :company_job, :company_title, :company_worktime1, :company_worktime2, :company_phone, :company_address, :company_weburl, :company_reamrk, :income, :social_security_id, :housing, :car, :house_address, :house_area, :house_year, :house_status, :house_holder1, :house_holder2, :house_right1, :house_right2, :house_loanyear, :house_loanprice, :house_balance, :house_bank, :mate_name, :mate_id_card, :mate_salary, :mate_phone, :mate_mobile, :mate_company_name, :mate_job, :mate_address, :qq, :avatar, :idcard_pic, :sms_verify_code, :gender_id)
    end

    def contact_params contact_id
      params.require(:"contact_#{contact_id}").permit(:relation, :name, :mobile, :company, :job_title)
    end
end