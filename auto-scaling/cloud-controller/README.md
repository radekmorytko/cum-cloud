# CloudController
Prototype of Cloud Controller of the Cloud-SAP architecture

## Usage
# Before executing
1. Create a configuration file, name it `config.yaml` and place it in the `config' directory.
2. `config-default.yaml` is the sample settings file. If you do not create your own, it will be used instead.
3. Make sure `controller_routing_key` has a *unique* value among controllers in your cloud configuration.
4. `$ bundle`

# Execution
1. Run `bin/intercloud_controller`
