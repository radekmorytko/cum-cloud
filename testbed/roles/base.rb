name "base"

env_run_lists "prod" => ["recipe[chef-client]"],
			  "_default" => ['recipe[yum]', 'recipe[chef-client]', 'recipe[hostname]', 'recipe[sudo]']

