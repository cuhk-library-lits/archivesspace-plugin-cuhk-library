ArchivesSpace::Application.routes.draw do
  scope AppConfig[:frontend_proxy_prefix] do
    match('/plugins/statistics' => 'statistics#index', :via => [:get])
  end
end