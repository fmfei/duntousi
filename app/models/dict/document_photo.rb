class Dict::DocumentPhoto < Dictionary
  translate_name
  class << self
    %w{ account_permits organization_code_certificate land_card business_license tax_registration_certificat}.each do |state|
      define_method state do |*args|
        self.find_by_name(state)
      end
    end
  end
end

