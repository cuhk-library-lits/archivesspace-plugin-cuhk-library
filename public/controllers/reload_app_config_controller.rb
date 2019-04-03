class ReloadAppConfigController < ApplicationController

  def reload
    AppConfigHelper.instance.reload
    render :text => AppConfig.dump_sanitized.to_s
  end

end
