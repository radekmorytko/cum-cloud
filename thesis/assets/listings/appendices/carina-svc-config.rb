ENDPOINT = {
	'mm01' => {
		:proxy   => 'http://192.168.0.35:2633/RPC2',
		:oneauth => "svc:xxxxx"
		}
	}


TEMPLATE = {
	'tomcat' => {
		:file       => "~/vm/tomcat.vm",
		:cpu        => "0.3",
		:memory     => 512,
		:network_id => { 'mm01' => 7 },
		:image_id   => { 'mm01' => 10 }
	},
	'haproxy' => {
		:file       => "~/vm/haproxy.vm",
		:cpu        => "0.3",
		:memory     => 512,
		:network_id => { 'mm01' => 7 },
		:image_id   => { 'mm01' => 11 }
	}
}


ENVIRONMENT = {
	'testenv' => {
                :type                  => "compute",
                :endpoint              => "mm01",
                :description           => "Example environment",
                :master_template       => "haproxy",
                :master_context_script => "sample-master-context-script.sh",
                :master_setup_time     => 30,
                :master_context_var    => "BALANCE_PORT=8080",
                :slave_template        => "tomcat",
                :slave_context_script  => "sample-slave-context-script.sh",
                :slave_context_var     => "APP_PACKAGE=gwt-petstore.war",
                :placement_policy      => "pack",
                :num_slaves            => 3,
                :slavedata             => "8080",
                :adminuser             => "root",
                :app_url               => "http://%MASTER%:8080/testapp"
	 }
}
