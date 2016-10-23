# -*- coding: utf-8 -*-

#coding: utf-8
require 'erb'
class Utils
  extend ActionView::Helpers::NumberHelper

  cattr_accessor :app_domain
  (ENV_SERVER=="test") ?  @production = false : @production = true

  class << self
    def encrypt(raw_data, salt = nil)
      require 'openssl' unless defined?(OpenSSL)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, salt || random_salt, raw_data.to_s)
    end

    def random_salt(size = 64)
      SecureRandom.hex(size)
    end

    def escape(url)
      URI.escape(url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    def target(str)
      YAML.load_file(Rails.root.join("lib/targets.yml")).with_indifferent_access[str]
    end

    def production?
      return @production
    end

    begin "month sta"
    def month_sta(date)
      time_sta date,"month"
    end

    def week_sta(date)
      time_sta date,"week"
    end

    def time_sta(date,time_str)
      t = DateTime.parse(date)
      t_e = t+1.days
      t_b = t
      if time_str=="month"
        t_b = t.beginning_of_month
      else
        t_b = t.beginning_of_week
      end
      borrowers = Account.borrowers.where(["created_at>=?",t_b]).where(["created_at<?",t_e])
      s1 = borrowers.size
      s2 = borrowers.find_all{|t| t.wizard_finished?}.size
      s3 = borrowers.find_all{|t| t.wizard_finished? and t.certificates.any?{|c| c.attachments.present?}}.size
      p "all:"+s1.to_s
      p "wizard_finished:"+s2.to_s
      p "wizard_finished attachments:"+s3.to_s
      p "total_loan_amount:"+BorrowerContract.where(["created_at>=?",t_b]).where(["created_at<?",t_e]).to_a.sum{|t| t.loan_amount.to_f + t.platform_fee.to_f}.to_s
      nil
    end
    end

  def show_me_the_money
    rows = []

    Info::Basic.where(mobile: "18611863187").includes(:account).all.each do |ib|
      ac = ib.account
      if ac.is_a? User::Lender
        rows << [ ac.id,
                  ac.name,
                  ac.total_amount.to_f,
                  ac.remaining_balance.to_f.round(2),
                  ac.funded_amount.to_f.round(2),
                  ac.asset.try(:invest_amount).to_f.round(2),
                  ac.remaining_seed_amount.to_f.round(2),
                ]
      end
    end

    rows << ["--", "--", rows.sum{|c| c[2] }, rows.sum{|c| c[3]}, rows.sum{|c| c[4]}, rows.sum{|c| c[5]}, rows.sum{|c| c[6]}]

    rows =  rows.map do |r|
      r.map do |r2|
        unless r2.is_a?(String) or r2.is_a?(Fixnum)
          number_to_currency r2
        else
          r2
        end
      end
    end

    puts Terminal::Table.new :headings => ['Id', 'Name', "Tot", "Cash", "Fun", "Asset", "Seed"], :rows => rows
  end



  def hjk
    hjk = Account.find(5168)
    loan_demand = hjk.loan_demand

    Bid.where(:loan_demand_id => loan_demand.id).each do |b|
      br = b.repayments.unpaid.order(:due_at).all
      r = hjk.repayments.true_unpaid.order(:due_at).all

      br.each_with_index do |c, i|
        c.update_attribute(:due_at, r[i].due_at)
      end
    end
  end

end

  def rmb(amount, mode = :y)
      ApplicationController.helpers.rmb(amount, mode = :y)
  end

  def self.attachments_support
    SimpleUploader::Attachment.find_each do |su|
      if File.exist?(su.path.to_s)
        su.attachment_fingerprint = Digest::MD5.file(su.path).hexdigest
        su.save!
        puts su.id
        path = Rails::root.to_s+"/public/system/"+su.attachment_fingerprint[0..5].split(//).join("/")+"/"+su.id.to_s+"/original/"
        Utils.mkdirs path
        FileUtils.cp(su.path,path)
      end
    end
  end

end
