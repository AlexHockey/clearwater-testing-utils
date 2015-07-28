name "ajh1"
description "Clearwater deployment - ajh1"
cookbook_versions "clearwater" => "= 0.1.0"
override_attributes "clearwater" => {
  "root_domain" => "cw-ngv.com",
  "availability_zones" => ["us-east-1a"],
  "repo_server" => "https://repo.cw-ngv.com/~ajh/uplevel",
  "number_start" => "2010000000",
  "number_count" => 1000,
  "keypair" => "dogfood-cw-keypair",
  "keypair_dir" => "~/.chef/",
  "pstn_number_count" => 0,
  "gr" => false,
  "sas_server" => "sas.cw-ngv.com",
  "cdiv_as_enabled" => "Y",
  "gemini_enabled" => "Y",
  "memento_enabled" => "Y",
}
