
require 'active_model'
require 'repositories_controller'

class CuhkLibRequestItem < RequestItem
  attr_accessor :user_type, :library_id

  def RequestItem.allow_for_type(repository_code, record_type)
    
    # Get repository uri from repository code (breaks MVC but repository_code is not static and can be changed)
    repo_uri = nil
    unless repository_code.nil? && repository_code.blank?
      ctrl = RepositoriesController.new
      repos_data = ctrl.archivesspace.search("(title:\"#{repository_code}\" AND publish:true)")
      if !repos_data['results'].blank?
        repo = ASUtils.json_parse(repos_data['results'][0]['json'])
        repo_uri = repo['uri']
      end
    end

    fallback = AppConfig[:pui_requests_permitted_for_types].include?(record_type)
    allowed_repo_types = AppConfig[:pui_repos].dig(repo_uri, :requests_permitted_for_types) if repo_uri

    if allowed_repo_types
      allowed_repo_types.include?(record_type)
    else
      fallback
    end
  end

  def RequestItem.allow_nontops(repo_code)
    allow = nil
    rep_allow = nil

    # Get repository uri from repository code (breaks MVC but repository_code is not static and can be changed)
    repo_uri = nil
    unless repo_code.nil? && repo_code.blank?
      ctrl = RepositoriesController.new
      repos_data = ctrl.archivesspace.search("(title:\"#{repo_code}\" AND publish:true)")
      if !repos_data['results'].blank?
        repo = ASUtils.json_parse(repos_data['results'][0]['json'])
        repo_uri = repo['uri']
      end
    end

    begin
      rep_allow  = AppConfig[:pui_repos].dig(repo_uri,:requests_permitted_for_containers_only) if repo_uri
      allow = !rep_allow unless rep_allow.nil?
    rescue Exception => err
      raise err unless err.message.start_with?("No value set for config parameter")
    end
    allow = !AppConfig[:pui_requests_permitted_for_containers_only] if allow.nil?
    Rails.logger.debug("allow? #{ allow}")
    allow
  end

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