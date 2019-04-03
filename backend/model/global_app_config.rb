class GlobalAppConfig < Sequel::Model(:global_app_config)
  include ASModel

  set_model_scope :global
  corresponds_to JSONModel(:global_app_config)

end