class StatisticsController < ApplicationController

  set_access_control  "view_repository" => [:show]

  def show
    JSONModel.with_repository(params[:repo_id]) do
        repo_app_configs = JSONModel(:repository_app_config).all
        repo_app_configs.each do |app_config|
          next unless app_config.config_key == ":repos_statistics"
          repos_statistics = JSON.parse(app_config.config_json, :symbolize_names => true) unless app_config.config_json.nil?
          @urls = repos_statistics[:urls]
        end
    end    
  end

end
