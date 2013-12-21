name "base"

env_run_lists "prod" => [],
			  "_default" => ['recipe[yum]', 'recipe[hostname]', 'recipe[sudo]']

