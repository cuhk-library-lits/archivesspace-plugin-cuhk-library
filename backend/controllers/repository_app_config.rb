class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/repositories/:repo_id/repository_app_configs')
    .description("Get list of repository app config by Repository ID")
    .params(["repo_id", :repo_id])
    .permissions([])
    .returns([200, "(:repository_app_config)"]) \
  do
    handle_unlimited_listing(RepositoryAppConfig, params)
  end

  Endpoint.get('/repositories/:repo_id/repository_app_configs/:id')
    .description("Get a repository app config by ID")
    .params(["id", :id],
            ["repo_id", :repo_id],
            ["resolve", :resolve])
    .permissions([])
    .returns([200, "(:repository_app_config)"]) \
  do
    json = RepositoryAppConfig.to_jsonmodel(params[:id])
    json_response(resolve_references(json, params[:resolve]))
  end

  Endpoint.post('/repositories/:repo_id/repository_app_configs')
    .description("Create repository app config")
    .params(["repo_id", :repo_id],
            ["repository_app_config", JSONModel(:repository_app_config), "The record to create", :body => true])
    .permissions([:administer_system])
    .returns([200, :created],
             [400, :error]) \
  do
    handle_create(RepositoryAppConfig, params[:repository_app_config])
  end

  Endpoint.post('/repositories/:repo_id/repository_app_configs/:id')
    .description("Update repository app config")
    .params(["id", :id],
            ["repository_app_config", JSONModel(:repository_app_config), "The updated record", :body => true],
            ["repo_id", :repo_id])
    .permissions([:administer_system])
    .returns([200, :updated],
             [400, :error]) \
  do
    handle_update(RepositoryAppConfig, params[:id], params[:repository_app_config])
  end

  Endpoint.delete('/repositories/:repo_id/repository_app_configs/:id')
    .description("Delete repository specific app config")
    .params(["id", :id],
            ["repo_id", :repo_id])
    .permissions([:administer_system])
    .returns([200, :deleted]) \
  do
    handle_delete(RepositoryAppConfig, params[:id])
  end

end