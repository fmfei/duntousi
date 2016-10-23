# encoding: utf-8
class Backend::OfflineBanksController < Backend::BaseController
	def index
		@title = '线下充值银行'
		@banks = OfflineBank.all
	end

	def new
		@title = '添加银行'
		@offline_bank = OfflineBank.new
	end

	def create
		@offline_bank = OfflineBank.new(bank_params)
    if @offline_bank.save
      flash[:success] = '添加成功'
      redirect_to backend_offline_banks_path
    else
      flash[:errors] = @offline_bank.errors
      render :new
    end
	end

	def edit
		@offline_bank = OfflineBank.find(params[:id])
	end

	def update
    @offline_bank = OfflineBank.find(params[:id])

    respond_to do |format|
      if @offline_bank.update_attributes(bank_params)
        format.html { redirect_to backend_offline_banks_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @offline_bank.errors, status: :unprocessable_entity }
      end
    end
	end

	def destroy
		offline_bank = OfflineBank.find(params[:id])
		offline_bank.destroy

    respond_to do |format|
      format.html { redirect_to backend_offline_banks_path }
      format.json { head :no_content }
    end
	end

	private

		def bank_params
			params.require(:offline_bank).permit(:name, :detail, :status)
		end


end
