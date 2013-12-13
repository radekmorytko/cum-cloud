## Usage
To deploy a service:

1. Prepare a JSON file with the following contents:
  - *name* of the service
  - list of stacks where each stack has *type* (e.g. java), the number of instances under key *instances*
2. Run client endpoint: `bin/intercloud_client_endpoint`
3. Make sure that *cloud broker* is running and its config/runtime parameters reflect those in client's config file under `config/config.yaml` or `config/config-default.yaml`
3. Run `bin/intercloud_client deploy -e _previously_created_json_file`

## Example JSON:
    {
       "name":"My service name",
       "stacks":[
          {
             "type":"java",
             "instances":3,
             "policy_set":{
                "min_vms":0,
                "max_vms":2,
                "policies":[
                   {
                      "name":"threshold_model",
                      "parameters":{
                         "min":"5",
                         "max":"50"
                      }
                   }
                ]
             }
          }
       ]
    }
