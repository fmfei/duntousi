class Dict::GenderType < Dictionary
  translate_name
  class << self
    %w{male female}.each do |state|
      define_method state do |*args|
        self.find_by_name(state)
      end
    end
  end
end