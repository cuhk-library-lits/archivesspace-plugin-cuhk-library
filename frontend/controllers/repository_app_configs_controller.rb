class RepositoryAppConfigsController < ApplicationController

  set_access_control  "administer_system" => [:index, :new, :edit, :create, :update, :delete]

  def index
    @repository_app_configs = JSONModel(:repository_app_config).all
  end

  def new
    @repository_app_config = JSONModel(:repository_app_config).new._always_valid!
  end

  def edit
    flash.keep if not flash.empty?
    @repository_app_config = JSONModel(:repository_app_config).find(params[:id])
  end

  def create
    handle_crud(
        :instance => :repository_app_config,
        :on_invalid => ->(){ render action: "new" },
        :on_valid => ->(id){
            redirect_to({
                :controller => :repository_app_configs,
                :action => :index,
                :id => id
            },
            :flash => {:success => I18n.t("repository_app_config.messages.created", JSONModelI18nWrapper.new(:repository_app_config => @repository_app_config))})
        }
    )
  end

  def update
    handle_crud(
        :instance => :repository_app_config,
        :obj => JSONModel(:repository_app_config).find(params[:id]),
        :on_invalid => ->(){ render action: "edit" },
        :on_valid => ->(id){
          redirect_to({
              :controller => :repository_app_configs,
              :action => :index,
              :id => id
          },
          :flash => {:success => I18n.t("repository_app_config.messages.updated", JSONModelI18nWrapper.new(:repository_app_config => @repository_app_config))})
        }
    )
  end

  def delete
    @repository_app_config = JSONModel(:repository_app_config).find(params[:id])
    @repository_app_config.delete

    flash[:success] = I18n.t("repository_app_config.messages.deleted", JSONModelI18nWrapper.new(:repository_app_config => @repository_app_config))
    redirect_to(:controller => :repository_app_configs, :action => :index, :deleted_uri => @repository_app_config.uri)
  end

end
