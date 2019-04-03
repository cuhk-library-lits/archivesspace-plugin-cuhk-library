class RepositoryAppConfig < Sequel::Model(:repository_app_config)
  include ASModel

  set_model_scope :repository
  corresponds_to JSONModel(:repository_app_config)

end