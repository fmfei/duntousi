class Dict::DegreeType < Dictionary
  translate_name 
  class << self
    %w{ other honorary_doctor doctor master bachelor unknown}.each do |state|
      define_method state do |*args|
        self.find_by_name(state)
      end
    end
  end
end