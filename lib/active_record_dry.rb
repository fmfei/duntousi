module ActiveRecordDry
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def has_city(prefix = nil)
      [:province, :city, :town].each do |t|
        belongs_to "#{prefix}#{t}", :class_name => "Dict::City"
      end

      include ActiveRecordDry::HasCity::InstanceMethods
    end

    def has_phone
      include ActiveRecordDry::HasPhone::InstanceMethods
    end

    def has_house_cost
      include ApplicationHelper
      include ActiveRecordDry::HasHouseCost::InstanceMethods
    end

    def translate_name
      include ActiveRecordDry::TranslateName::InstanceMethods
    end

    def translate_key
      include ActiveRecordDry::TranslateKey::InstanceMethods
    end

    def acts_as_list_item
      extend ActiveRecordDry::ListItem::SingletonMethods

      scope :within, lambda{|ids| where(ids.blank? ? "1=2" : "id in (#{ids.join(',')})")}
      scope :without, lambda{|ids| where(ids.blank? ? "1=1" : "id not in (#{ids.join(',')})")}
    end
  end

  module HasCity
    module InstanceMethods
      def address(prefix = nil)
        [:province, :city, :town].map{|t|
          text = self.send("#{prefix}#{t}").try(:name)
          text = "" if text == I18n.t("hidden_city")
          text
        }.join +
          (self.respond_to?("#{prefix}street") ? self.send("#{prefix}street").to_s : "")
      end
    end
  end

  module HasPhone
    module InstanceMethods
      def full_phone
        "#{self.phone_ext} - #{self.phone}"
      end
    end
  end

  module TranslateName
    module InstanceMethods
      def name
        I18n.t("#{self.class.to_s}.#{self.attributes["name"]}")
      end

      def db_name
        self.attributes["name"]
      end
    end
  end

  module TranslateKey
    module InstanceMethods
      def key
        I18n.t("#{self.class.to_s}.#{self.attributes["key"]}")
      end

      def db_name
        self.attributes["key"]
      end
    end
  end

  module HasHouseCost
    module InstanceMethods
      def house_cost_label
        case self.house_type_id
        when Dict::HouseType.loan_id
          I18n.t(:loan_fee)
        when Dict::HouseType.rent_id
          I18n.t(:rent_fee)
        else
          ""
        end
      end

      def house_cost_desc
        "#{self.house_type.try(:name)} #{self.house_cost_label.blank? ? "" : "#{self.house_cost_label} #{rmb(self.house_cost, :ym)}" }".html_safe
      end
    end
  end

  module ListItem
    module SingletonMethods
      def list_for_select(collection = nil, with_children = false)
        (collection || self.all).map{|city| with_children ? [city.name, city.children.map{|i| [i.name, i.id]}] : [city.name, city.id]}
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecordDry)