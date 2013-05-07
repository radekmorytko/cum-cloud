#### app-specific variables
default[:app][:name] = 'demoapp'

#### apache mod_jk variables
default[:mod_jk][:tomcat_workers] = {
  :worker1 => {
    :type=>'ajp13',
    :port=>8009,
    :host=>'localhost',
    :lbfactor=>3
  }
}


default[:mod_jk][:loadbalancer] = {
    :balance_workers => default[:mod_jk][:tomcat_workers].keys
}



