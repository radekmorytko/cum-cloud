name "base"

env_run_lists "prod" => ["recipe[chef-client]"],
			  "_default" => ['recipe[yum]', 'recipe[hostname]', 'recipe[chef-client]']
