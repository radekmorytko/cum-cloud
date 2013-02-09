SHAREDPOOLS = {
    'mm01' => {
        :zone => 'helix',
        :allocateable_cpus => '20',
        :allocateable_mem  => '4048',
        :service_class     => 'silver'
     }
}

SERVICES = {
   'service1' => {
        :priority => 'silver',
        :maxcpus => '12',
        :maxmemory => '64000',
    },
}

