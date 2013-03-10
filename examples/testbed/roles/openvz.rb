name "openvz"

run_list(
  'recipe[opennebula::openvz]',
)

override_attributes({
    :authorization => {
      :sudo => {
        :passwordless => true,
        :users => [
          "oneadmin",
          "ubuntu"
        ]
      }
   }
})
