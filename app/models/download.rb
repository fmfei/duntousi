class Download < ActiveRecord::Base
  # attr_accessible :name, :file, :description
  mount_uploader :file, FileUploader

end
