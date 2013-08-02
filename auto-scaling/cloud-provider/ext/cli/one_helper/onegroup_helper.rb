# -------------------------------------------------------------------------- #
# Copyright 2002-2013, OpenNebula Project Leads (OpenNebula.org)             #
#                                                                            #
# Licensed under the Apache License, Version 2.0 (the "License"); you may    #
# not use this file except in compliance with the License. You may obtain    #
# a copy of the License at                                                   #
#                                                                            #
# http://www.apache.org/licenses/LICENSE-2.0                                 #
#                                                                            #
# Unless required by applicable law or agreed to in writing, software        #
# distributed under the License is distributed on an "AS IS" BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.   #
# See the License for the specific language governing permissions and        #
# limitations under the License.                                             #
#--------------------------------------------------------------------------- #

require 'one_helper'
require 'one_helper/onequota_helper'

class OneGroupHelper < OpenNebulaHelper::OneHelper
    def self.rname
        "GROUP"
    end

    def self.conf_file
        "onegroup.yaml"
    end

    def create_resource(options, &block)
        group = factory

        rc = block.call(group)
        if OpenNebula.is_error?(rc)
            return -1, rc.message
        else
            puts "ID: #{group.id.to_s}"
        end

        puts "Creating default ACL rules from #{GROUP_DEFAULT}" if options[:verbose]

        exit_code , msg = group.create_acls

        puts msg 

        exit_code
    end

    def format_pool(options)
        config_file = self.class.table_conf

        table = CLIHelper::ShowTable.new(config_file, self) do
            column :ID, "ONE identifier for the Group", :size=>4 do |d|
                d["ID"]
            end

            column :NAME, "Name of the Group", :left, :size=>29 do |d|
                d["NAME"]
            end

            column :USERS, "Number of Users in this group", :size=>5 do |d|
                if d["USERS"]["ID"].nil?
                    "0"
                else
                    d["USERS"]["ID"].size
                end
            end

            column :VMS , "Number of VMS", :size=>9 do |d|             
                if d.has_key?('VM_QUOTA') and d['VM_QUOTA'].has_key?('VM')
                    "%3d / %3d" % [d['VM_QUOTA']['VM']["VMS_USED"], d['VM_QUOTA']['VM']["VMS"]]
                else
                    "-"
                end
            end

            column :MEMORY, "Total memory allocated to user VMs", :size=>17 do |d|
                if d.has_key?('VM_QUOTA') and d['VM_QUOTA'].has_key?('VM')
                    "%7s / %7s" % [OpenNebulaHelper.unit_to_str(d['VM_QUOTA']['VM']["MEMORY_USED"].to_i,{},"M"),
                    OpenNebulaHelper.unit_to_str(d['VM_QUOTA']['VM']["MEMORY"].to_i,{},"M")]
                else
                    "-"
                end
            end

            column :CPU, "Total CPU allocated to user VMs", :size=>11 do |d|
                if d.has_key?('VM_QUOTA') and d['VM_QUOTA'].has_key?('VM')
                    "%4.0f / %4.0f" % [d['VM_QUOTA']['VM']["CPU_USED"], d['VM_QUOTA']['VM']["CPU"]]
                else
                    "-"
                end
            end

            default :ID, :NAME, :USERS, :VMS, :MEMORY, :CPU
        end

        table
    end

    private

    def factory(id=nil)
        if id
            OpenNebula::Group.new_with_id(id, @client)
        else
            xml=OpenNebula::Group.build_xml
            OpenNebula::Group.new(xml, @client)
        end
    end

    def factory_pool(user_flag=-2)
        #TBD OpenNebula::UserPool.new(@client, user_flag)
        OpenNebula::GroupPool.new(@client)
    end

    def format_resource(group)
        str="%-15s: %-20s"
        str_h1="%-80s"

        CLIHelper.print_header(str_h1 % "GROUP #{group['ID']} INFORMATION")
        puts str % ["ID",   group.id.to_s]
        puts str % ["NAME", group.name]
        puts

        CLIHelper.print_header(str_h1 % "USERS", false)
        CLIHelper.print_header("%-15s" % ["ID"])
        group.user_ids.each do |uid|
            puts "%-15s" % [uid]
        end

        group_hash = group.to_hash

        OneQuotaHelper.format_quota(group_hash['GROUP'])
    end
end
