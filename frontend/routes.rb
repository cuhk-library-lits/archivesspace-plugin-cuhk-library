ArchivesSpace::Application.routes.draw do
  scope AppConfig[:frontend_proxy_prefix] do
    match('/plugins/statistics/:repo_id' => 'statistics#show', :via => [:get])
  end
end