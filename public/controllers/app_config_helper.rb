require 'singleton'
require 'jsonmodel'
require 'jsonmodel_client'
require 'bigdecimal'

class AppConfigHelper
    include Singleton
    include JSONModel

    @global_app_configs
    @repository_app_configs

    def initialize
        while true
            begin
                JSONModel::init(:client_mode => true, :url => AppConfig[:backend_url])
                break
            rescue
                $stderr.puts("AppConfigHelper: Connection to backend failed (#{$!}).  Retrying...")
                sleep(5)
            end
        end
    end    

    def reload
        @global_app_configs = JSONModel(:global_app_config).all        

        repos = JSONModel(:repository).all
        repos.each do |repo|
            JSONModel.with_repository(JSONModel(:repository).id_for(repo.uri)) do
                @repository_app_configs = {} if @repository_app_configs.nil?
                @repository_app_configs[repo.repo_code.downcase] = JSONModel(:repository_app_config).all
            end
        end

        @global_app_configs.each do |app_config|
            app_config_key = app_config.config_key.start_with?(":") ? app_config.config_key.from(1).to_sym : app_config.config_key
            app_config_value = app_config.config_json
            unless app_config_value.nil?
                begin
                    app_config_value = JSON.parse(app_config_value, :symbolize_names => true)
                    if app_config_value.has_key?(:__boolean__)
                        app_config_value = app_config_value[:__boolean__]
                    elsif app_config_value.has_key?(:__decimal__)
                        app_config_value = app_config_value[:__decimal__].to_d
                    elsif app_config_value.has_key?(:__array__)
                        app_config_value = app_config_value[:__array__]
                    end
                rescue JSON::ParserError
                    nil
                end
            end
            AppConfig[app_config_key] = app_config_value
        end

        @repository_app_configs.each do |repo_code, repo_app_configs|
            next if repo_app_configs.nil?
            repo_app_configs.each do |app_config|
                app_config_key = app_config.config_key.start_with?(":") ? app_config.config_key.from(1).to_sym : app_config.config_key
                app_config_value = app_config.config_json
                unless app_config_value.nil?
                    begin
                        app_config_value = JSON.parse(app_config_value, :symbolize_names => true)
                        if app_config_value.has_key?(:__boolean__)
                            app_config_value = app_config_value[:__boolean__]
                        elsif app_config_value.has_key?(:__decimal__)
                            app_config_value = app_config_value[:__decimal__].to_d
                        elsif app_config_value.has_key?(:__array__)
                            app_config_value = app_config_value[:__array__]
                        end
                    rescue JSON::ParserError
                        nil
                    end
                end
                AppConfig[app_config_key][repo_code] = app_config_value
            end
        end

        $stdout.puts("AppConfigHelper: Additional config reloaded.")
    end

    def global_app_configs
        @global_app_configs
    end

    def repository_app_configs(uri)
        repository_app_configs.key?(uri) ? @repository_app_configs[uri] : nil
    end

end
