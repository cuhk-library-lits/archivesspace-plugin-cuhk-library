Sequel.migration do
  up do

    create_table(:global_app_config) do
      primary_key :id

      Integer :lock_version, :default => 0, :null => false
      Integer :json_schema_version, :null => false

      String :config_key, :null => false
      TextBlobField :config_json, :null => true

      apply_mtime_columns
    end

    add_index :global_app_config, [:config_key], unique: true

  end

  down do
    drop_table(:global_app_config)
  end

end