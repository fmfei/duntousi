class Dict::EducationType < Dictionary
  translate_name 
  class << self
    %w{ unmarried married first_married sec_married remarried  widowed divorce unknown}.each do |state|
      define_method state do |*args|
        self.find_by_name(state)
      end
    end
  end
end