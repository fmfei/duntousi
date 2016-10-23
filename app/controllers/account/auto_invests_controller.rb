# encoding: utf-8
class Account::AutoInvestsController < Account::BaseController

  def index
    @auto_invest_rules = current_user.auto_invest_rules.paginate :page => params[:page], :per_page => 20
  end

  def new
    @auto_invest_rule = current_user.auto_invest_rules.new
  end

  def bank
    puts 1
  end

  def create
    if params[:active] == '1'
      params[:auto_invest_rule]['actived_at'] = DateTime.now
    end
    @auto_invest_rule = current_user.auto_invest_rules.new(auto_params)
    if @auto_invest_rule.save
      flash[:success] = '添加成功'
      redirect_to account_auto_invests_path
    else
      flash[:errors] = @auto_invest_rule.errors
      render :new
    end
  end

  def edit
    @auto_invest_rule = current_user.auto_invest_rules.find(params[:id])
  end

  def update
    @auto_invest_rule = current_user.auto_invest_rules.find(params[:id])
    if params[:active] != '1'
      params[:auto_invest_rule]['actived_at'] = nil
    else
      params[:auto_invest_rule]['actived_at'] = @auto_invest_rule.actived_at || Time.now
    end

    respond_to do |format|
      if @auto_invest_rule.update_attributes(auto_params)
        format.html { redirect_to account_auto_invests_path, notice: '更新成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @auto_invest_rule.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @auto_invest_rule = current_user.auto_invest_rules.find(params[:id])
    @auto_invest_rule.destroy

    respond_to do |format|
      format.html { redirect_to(account_auto_invests_path) }
      format.xml  { head :ok }
    end
  end

  private

  def auto_params
    params.require(:auto_invest_rule).permit(:amount, :min_interest, :max_interest, :min_months, :max_months, :with_mortgage, :with_guarantee, :repay_style, :remain_amount, :actived_at, :queue)
  end

end