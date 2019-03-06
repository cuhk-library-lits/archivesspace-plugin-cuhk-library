
require 'active_model'

class CuhkLibRequestItem < RequestItem
  attr_accessor :user_type, :library_id

  def initialize(hash)
    self.members.each do |sym|
      self[sym] = hash.fetch(sym,nil)
    end
    self.user_type =  hash.fetch("user_type",nil)
    self.library_id = hash.fetch("library_id",nil)
  end

  def validate
    errs = super
    errs.push(I18n.t('request.errors.user_type')) if self.user_type.blank?
    errs
  end

  def detailed_info()
    info = {}

    info[:request_uri] = AppConfig[:public_proxy_url].sub(/\/^/, '') + self[:request_uri]

    %i(repo_name title resource_name cite identifier resource_id restrict hierarchy).each do |sym|
      value = self[sym].to_s
      if self[sym].respond_to?(:to_ary)
        value = self[sym].join(' / ')
      end
      info[sym.to_s] = value unless value.blank?
    end

    if !self[:container].blank? && !self[:container].empty?
      self[:container].each_with_index do |v, i|
        info[:top_container_url] = defined?(self[:top_container_url][i]) ? AppConfig[:public_proxy_url].sub(/\/^/, '') + self[:top_container_url][i] : ""
        %i(container  barcode).each do |sym|
          info[sym.to_s] = defined?(self[sym][i]) ? self[sym][i] : ""
        end

        info[:location_url] = defined?(self[:location_url][i]) ? AppConfig[:public_proxy_url].sub(/\/^/, '') + self[:location_url][i] : ""
        info[:location_title] = defined?(self[:location_title][i]) ? self[:location_title][i] : ""
      end
    end

    info
    
  end
  
end