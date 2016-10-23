# coding: utf-8
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :destroy, :to => :crd
    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.has_role? '超级管理员'
      can :manage, :all
    else
      user.permissions.each do |p|
        begin
          action = p.action.to_sym
          subject = begin
                      # RESTful Controllers
                      p.subject.camelize.constantize
                    rescue
                      # Non RESTful Controllers
                      p.subject.underscore
                    end
          can action, subject
          Rails.logger.info "#{action}--->#{subject}"
        rescue => e
          Rails.logger.info "Error: #{subject}-> #{e}"
        end
      end
    end
  end
end
