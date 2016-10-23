class Dictionary < ActiveRecord::Base
  # attr_accessible :code, :introduction, :name, :position, :type
  acts_as_list
  # acts_as_list_item
end