class Dict::LoanState < Dictionary
  translate_name
	
	scope :statistic_need, lambda{where("name != 'overdue' and name != 'bids_auditing'") }
  
  class << self
    %w{junior_auditing senior_auditing wait_to_bid bidding failed bids_auditing repaying overdue finished}.each do |state|
      define_method state do |*args|
        self.find_by_name(state)
      end
    end

  end
end