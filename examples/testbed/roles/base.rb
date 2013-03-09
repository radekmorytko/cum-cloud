name "base"

run_list(
  'recipe[apt]',
  'recipe[hostname]',
  'recipe[sudo]',
# production env. only: (run chef-client as a daemon)
# 'recipe[chef-client]'
)

override_attributes({
#  :chef_client => {
#    :interval => 10
#  },
  "authorization" => { 
	"sudo" => { 
		"users" => ["oneadmin"], 
		"passwordless" => true,
	} } 
})
