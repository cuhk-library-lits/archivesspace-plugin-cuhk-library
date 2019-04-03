Sequel.migration do
  up do

    create_table(:repository_app_config) do |t|
      primary_key :id

      Integer :lock_version, :default => 0, :null => false
      Integer :json_schema_version, :null => false

      Integer :repo_id, :null => false
      String :config_key, :null => false
      TextBlobField :config_json, :null => true

      apply_mtime_columns
    end

    add_index :repository_app_config, [:config_key, :repo_id], unique: true

    alter_table(:repository_app_config) do
      add_foreign_key([:repo_id], :repository, :key => :id)
    end

  end

  down do
    drop_table(:repository_app_config)
  end

end