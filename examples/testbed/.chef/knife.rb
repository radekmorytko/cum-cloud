current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "dchrzascik"
client_key               "#{current_dir}/dchrzascik.pem"
validation_client_name   "cheftry-validator"
validation_key           "#{current_dir}/cheftry-validator.pem"
chef_server_url          "https://api.opscode.com/organizations/cheftry"
cache_type               'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path            ["#{current_dir}/../cookbooks"]
