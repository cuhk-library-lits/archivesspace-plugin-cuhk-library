class RefreshPuiAppConfigsController < ApplicationController

  set_access_control  "administer_system" => [:index]

  def index
    pui_refresh_uri = URI(AppConfig[:public_proxy_url] + '/reload_app_config')
    Net::HTTP.start(pui_refresh_uri.host, pui_refresh_uri.port) do |http|
      request = Net::HTTP::Get.new pui_refresh_uri
      response = http.request request

      flash.clear
      if response.code === "200"
        flash[:success] = I18n.t("plugins.refresh_pui_app_configs.messages.pui_refresh_success")
      else
        flash[:error] = I18n.t("plugins.refresh_pui_app_configs.messages.pui_refresh_failed")
      end
    end
  end

end