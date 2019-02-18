class StatisticsController < ApplicationController

  set_access_control  "view_repository" => [:index]

  def index
    @cat = {}
    @cat["key"] = "value"
  end

end
