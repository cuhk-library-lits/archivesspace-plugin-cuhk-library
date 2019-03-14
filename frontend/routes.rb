ArchivesSpace::Application.routes.draw do
  scope AppConfig[:frontend_proxy_prefix] do
    match('/plugins/statistics/:repo_id' => 'statistics#show', :via => [:get])
    match('/plugins/system_status' => 'system_status#save', :via => [:post])
  end
end