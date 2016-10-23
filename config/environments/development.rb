# encoding: utf-8
Lending::Application.configure do
  require File.expand_path('../../cus_env.rb', __FILE__)
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
#  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
#  config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  config.action_mailer.default_url_options = { host: 'yataitouzi.com' }
  config.action_mailer.delivery_method =:smtp
  # config.action_mailer.smtp_settings = {
  #   :address => "smtp.163.com",
  #   :port => 25,
  #   :authentication => "login",
  #   :user_name => "weigang992003@163.com",
  #   :password => "1q2w3e4r$",
  #   :enable_starttls_auto => true
  # }
  config.action_mailer.smtp_settings = {
    :address => "smtp.yataitouzi.com",
    :port => 25,
    :authentication => "login",
    :user_name => "info",
    :password => "yataitouzi@1011",
    :enable_starttls_auto => true
  }
  
end
