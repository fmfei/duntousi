# coding: utf-8
class FrontConfig
  require 'ya2yaml'

  #为提高读取速度，配置文件写在yaml文件里
  def self.site_avaliable
    self.get_config['config']['site_avaliable']
  end

  def self.save_site_status(status=false)
    rules = self.get_config
    rules['config']['site_avaliable'] = status
    self.save(rules)
  end

  def self.get_config  
    YAML::load(File.read("#{Rails.root}/config/front_config.yml"))  
  end

  def self.save(rules)
    result = true
    begin
      File.open("#{Rails.root}/config/front_config.yml", 'w') { |f|
        #YAML.dump(rules, f)
        f.puts rules.ya2yaml
      }
   rescue => err
     logger = Logger.new("#{Rails.root}/log/err.log")
     logger.error err
     logger.close     
     result = false
   end
   result
  end
end
