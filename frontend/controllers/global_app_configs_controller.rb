class GlobalAppConfigsController < ApplicationController

  set_access_control  "administer_system" => [:index, :new, :edit, :create, :update, :delete]

  def index
    @global_app_configs = JSONModel(:global_app_config).all
  end

  def new
    @global_app_config = JSONModel(:global_app_config).new._always_valid!
  end

  def edit
    flash.keep if not flash.empty?
    @global_app_config = JSONModel(:global_app_config).find(params[:id])
  end

  def create
    handle_crud(
        :instance => :global_app_config,
        :on_invalid => ->(){ render action: "new" },
        :on_valid => ->(id){
            redirect_to({
                :controller => :global_app_configs,
                :action => :index,
                :id => id
            },
            :flash => {:success => I18n.t("global_app_config.messages.created", JSONModelI18nWrapper.new(:global_app_config => @global_app_config))})
        }
    )
  end

  def update
    handle_crud(
        :instance => :global_app_config,
        :obj => JSONModel(:global_app_config).find(params[:id]),
        :on_invalid => ->(){ render action: "edit" },
        :on_valid => ->(id){
          redirect_to({
              :controller => :global_app_configs,
              :action => :index,
              :id => id
          },
          :flash => {:success => I18n.t("global_app_config.messages.updated", JSONModelI18nWrapper.new(:global_app_config => @global_app_config))})
        }
    )
  end

  def delete
    @global_app_config = JSONModel(:global_app_config).find(params[:id])
    @global_app_config.delete

    flash[:success] = I18n.t("global_app_config.messages.deleted", JSONModelI18nWrapper.new(:global_app_config => @global_app_config))
    redirect_to(:controller => :global_app_configs, :action => :index, :deleted_uri => @global_app_config.uri)
  end

end
