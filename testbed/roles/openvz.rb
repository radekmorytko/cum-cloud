name "openvz"

run_list(
  'recipe[opennebula::openvz]','recipe[sudo]'
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
