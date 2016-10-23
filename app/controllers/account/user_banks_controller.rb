# encoding: utf-8
class Account::UserBanksController < Account::BaseController

  # 银行卡管理
  def index
    @banks = current_user.user_banks.order("created_at desc").paginate :page => params[:page], :per_page => 20
    @title = '银行卡管理'
  end

  # 添加银行卡
  def new
    @bank = current_user.user_banks.new
    @title = '添加银行卡'
  end

  def create
    @bank = current_user.user_banks.new(bank_params)
    if @bank.save
      flash[:success] = '添加成功'
      redirect_to account_banks_path
    else
      flash[:errors] = @bank.errors
      render :new
    end
  end

  def edit
    @bank = UserBank.find(params[:id])
  end

  def update
    @bank = UserBank.find(params[:id])

    respond_to do |format|
      if @bank.save && @bank.update_attributes(bank_params)
        format.html { redirect_to account_banks_path, notice: '更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @bank.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bank = UserBank.find(params[:id])
    @bank.destroy

    respond_to do |format|
      format.html { redirect_to(account_banks_path) }
      format.xml  { head :ok }
    end
  end

  private
  def bank_params
    params.require(:user_bank).permit(:card_number, :bank, :branch, :province, :city, :area)
  end

end