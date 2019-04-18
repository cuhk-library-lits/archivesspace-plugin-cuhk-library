class ReloadAppConfigController < ApplicationController

  def reload
    AppConfigHelper.instance.reload
    render :text => "AppConfig reloaded at: " + Time.now.strftime("%Y-%m-%d %H:%M:%S") + " (#{Time.zone.to_s})"
  end

end
