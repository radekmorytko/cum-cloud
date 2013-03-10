name "frontend"

run_list(
  'recipe[opennebula::frontend]',
)

override_attributes({
  :opennebula => {
    :home => "/var/lib/one"
  }
})
