name "base"

env_run_lists "prod" => ["recipe[chef-client]"],
			  "_default" => ['recipe[apt]', 'recipe[hostname]', 'recipe[sudo]']

override_attributes( {
    :authorization => {
      :sudo => {
        :users => [
          "ubuntu"
        ]
      }
   }
} )
