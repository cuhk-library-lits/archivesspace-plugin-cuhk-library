ArchivesSpace::Application.routes.draw do
  scope AppConfig[:frontend_proxy_prefix] do
    match('/plugins/statistics/:repo_id' => 'statistics#show', :via => [:get])

    match('/plugins/global_app_configs/new' => 'global_app_configs#new', :via => [:get])
    match('/plugins/global_app_configs/:id/edit' => 'global_app_configs#edit', :via => [:get])
    match('/plugins/global_app_configs' => 'global_app_configs#create', :via => [:post])
    match('/plugins/global_app_configs/:id' => 'global_app_configs#update', :via => [:post])
    match('/plugins/global_app_configs/:id/delete' => 'global_app_configs#delete', :via => [:post])

    match('/plugins/repository_app_configs/new' => 'repository_app_configs#new', :via => [:get])
    match('/plugins/repository_app_configs/:id/edit' => 'repository_app_configs#edit', :via => [:get])
    match('/plugins/repository_app_configs' => 'repository_app_configs#create', :via => [:post])
    match('/plugins/repository_app_configs/:id' => 'repository_app_configs#update', :via => [:post])
    match('/plugins/repository_app_configs/:id/delete' => 'repository_app_configs#delete', :via => [:post])
  end
end