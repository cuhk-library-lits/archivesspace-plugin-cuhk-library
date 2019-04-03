class ArchivesSpaceService < Sinatra::Base

  Endpoint.get('/global_app_configs')
    .description("Get list of global app configs")
    .params()
    .permissions([])
    .returns([200, "{(:global_app_config)}"]) \
  do
    handle_unlimited_listing(GlobalAppConfig)
  end

  Endpoint.get('/global_app_configs/:id')
    .description("Get a global app config")
    .params(["id", Integer, "The ID of the global app config to retrieve"])
    .permissions([])
    .returns([200, "(:global_app_config)"]) \
  do
     json_response(GlobalAppConfig.to_jsonmodel(params[:id]))
  end

  Endpoint.post('/global_app_configs')
    .description("Create global app config")
    .params(["global_app_config", JSONModel(:global_app_config), "The record to create", :body => true])
    .permissions([:administer_system])
    .returns([200, :created],
             [400, :error]) \
  do
    handle_create(GlobalAppConfig, params[:global_app_config])
  end

  Endpoint.post('/global_app_configs/:id')
    .description("Update global app config")
    .params(["id", :id],
            ["global_app_config", JSONModel(:global_app_config), "The updated record", :body => true])
    .permissions([:administer_system])
    .returns([200, :updated],
             [400, :error]) \
  do
    handle_update(GlobalAppConfig, params[:id], params[:global_app_config])
  end

  Endpoint.delete('/global_app_configs/:id')
    .description("Delete global app config")
    .params(["id", :id])
    .permissions([:administer_system])
    .returns([200, :deleted]) \
  do
    handle_delete(GlobalAppConfig, params[:id])
  end

end