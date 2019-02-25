class StatisticsController < ApplicationController

  set_access_control  "view_repository" => [:show]

  def show
    @repository = JSONModel(:repository_with_agent).find(params[:repo_id])
  end

end
