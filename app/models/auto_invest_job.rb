class AutoInvestJob
	@queue = :high

  def self.perform(job_name, options)
  	self.send(job_name, options)
  end

	# 
	def self.invest loan_id
		if loan_id.present?
			AutoInvestRule.exec_for(loan_id)
		end
	end

end