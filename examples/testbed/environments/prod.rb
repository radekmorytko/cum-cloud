name "prod"

description "The production environment"

override_attributes({
  :chef_client => {
    :interval => 600
  },
})

