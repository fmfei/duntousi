class EmailJob
	@queue = :high

  def self.perform(job_name, options)
  	self.send(job_name, options)
  end

	# cofirm email
	def self.send_confirmation options
		user = User.find options["user_id"]

		o = [('a'..'z'), ('A'..'Z'),('1'..'9')].map { |i| i.to_a }.flatten
		token = (0...20).map { o[rand(o.length)] }.join
		user.update_attribute(:confirmation_token, token)
		user.update_attribute(:confirmation_sent_at, Time.now)

		UserMailer.confirmation(user).deliver_now
	end

  def self.send_lender options
    user = User.find options["user_id"]
    UserMailer.send_lender(user).deliver_now
  end

end