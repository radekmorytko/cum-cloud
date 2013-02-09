ENDPOINT = {
	'mm01' => {
		:proxy   => 'http://localhost:2633/RPC2',
		:oneauth => "service1:password"
		}
	}


TEMPLATE = {
	'ubuntu1204-small' => {
		:file       => "~/vm/ubuntu1204.vm",
		:cpu        => 1,
		:memory     => 256,
		:network_id => { 'mm01' => 3 },
		:image_id   => { 'mm01' => 14 }
	}
}


ENVIRONMENT = {
	'tomcat' => {
                :type => "compute",
                :endpoint => "mm01",
                :description => "Load-balanced Tomcat cluster",
		:master_template   => "ubuntu1204-small",
                :master_context_script =>  "balance.sh",
		:master_setup_time => 30,
                :master_context_var => "BALANCE_PORT=8080",
		:slave_template    => "ubuntu1204-small",
                :slave_context_script => "tomcat.sh",
                :slave_context_var => "APP_PACKAGE=gwt-petstore.war",
                :placement_policy  => "pack",
                :num_slaves        => 1,
                :slavedata         => "8080",
                :adminuser         => "ubuntu",
                :app_url           => "http://%MASTER%:8080/gwt-petstore"
	 },

        'tomcat-cluster' => {
                :type => "compute",
                :endpoint => "mm01",
                :description => "Load-balanced Tomcat cluster",
                :master_template   => "ubuntu1204-small",
                :master_context_script =>  "balance-mod-jk.sh",
                :master_setup_time => 30,
                :master_context_var => "\"APP_PATH=demoapp, AJP_PORT=8009\"",
                :slave_template    => "ubuntu1204-small",
                :slave_context_script => "tomcat-cluster.sh",
                :slave_context_var => "\"APP_PACKAGE=demoapp.war, AJP_PORT=8009\"",
                :placement_policy  => "pack",
                :num_slaves        => 1,
                :slavedata         => "8080",
                :adminuser         => "ubuntu",
                :app_url           => "http://%MASTER%/demoapp"
         }


}
