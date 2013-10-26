name "carina"

run_list(
  'recipe[mysql::server]',
  'recipe[mysql::client]',
  'recipe[redisio::install]',
  'recipe[redisio::enable]',
  'recipe[apache2]',
  'recipe[carina]'
)

override_attributes({
  :mysql => {
    :server_root_password => "mysecretpassword",
  },
  
  :authorization => {
    :sudo => {
      :passwordless => true,
      :users => [
        "carina",
        "ubuntu"
      ]
   }
 }
})
