{
  :schema => {
    "$schema" => "http://www.archivesspace.org/archivesspace.json",
    "version" => 1,
    "type" => "object",
    "uri" => "/global_app_configs",
    "properties" => {
      "config_key" => {"type" => "string", "required" => true},
      "config_json" => {"type" => "string", "required" => false},

      # For frontend, not stored in database
      "uri" => {"type" => "string", "required" => false}
    },
    "additionalProperties" => false,
  },
}