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

class AcctHelper < OpenNebulaHelper::OneHelper
    START_TIME = {
        :name   => "start_time",
        :short  => "-s TIME",
        :large  => "--start TIME" ,
        :description => "Start date and time to take into account",
        :format => String # TODO Time
    }

    END_TIME = {
        :name   => "end_time",
        :short  => "-e TIME",
        :large  => "--end TIME" ,
        :description => "End date and time",
        :format => String # TODO Time
    }

    USER = {
        :name   => "user",
        :short  => "-u user",
        :large  => "--user user" ,
        :description => "User name or id to filter the results",
        :format => String,
        :proc => lambda { |o, options|
            OpenNebulaHelper.rname_to_id(o, "USER")
        }
    }

    GROUP = {
        :name   => "group",
        :short  => "-g group",
        :large  => "--group group" ,
        :description => "Group name or id to filter the results",
        :format => String,
        :proc => lambda { |o, options|
            puts o
            OpenNebulaHelper.rname_to_id(o, "GROUP")
        }
    }

    HOST = {
        :name   => "host",
        :short  => "-H HOST",
        :large  => "--host HOST" ,
        :description => "Host name or id to filter the results",
        :format => String,
        :proc => lambda { |o, options|
            OpenNebulaHelper.rname_to_id(o, "HOST")
        }
    }

    XPATH = {
        :name   => "xpath",
        :large  => "--xpath XPATH_EXPRESSION" ,
        :description => "Xpath expression to filter the results. \
            For example: oneacct --xpath 'HISTORY[ETIME>0]'",
        :format => String
    }

    XML = {
        :name  => "xml",
        :short => "-x",
        :large => "--xml",
        :description => "Show the resource in xml format"
    }

    JSON = {
        :name  => "json",
        :short => "-j",
        :large => "--json",
        :description => "Show the resource in xml format"
    }

    SPLIT={
        :name  => "split",
        :large => "--split",
        :description => "Split the output in a table for each VM"
    }

    ACCT_OPTIONS = [START_TIME, END_TIME, USER, GROUP, HOST, XPATH, XML, JSON, SPLIT]


    ACCT_TABLE = CLIHelper::ShowTable.new("oneacct.yaml", nil) do
        column :VID, "Virtual Machine ID", :size=>4 do |d|
            d["OID"]
        end

        column :SEQ, "History record sequence number", :size=>3 do |d|
            d["SEQ"]
        end

        column :HOSTNAME, "Host name", :left, :size=>15 do |d|
            d["HOSTNAME"]
        end

        column :REASON, "VM state change reason", :left, :size=>4 do |d|
            VirtualMachine.get_reason d["REASON"]
        end

        column :START_TIME, "Start time", :size=>14 do |d|
            OpenNebulaHelper.time_to_str(d['STIME'])
        end

        column :END_TIME, "End time", :size=>14 do |d|
            OpenNebulaHelper.time_to_str(d['ETIME'])
        end

        column :MEMORY, "Assigned memory", :size=>6 do |d|
            OpenNebulaHelper.unit_to_str(d["VM"]["TEMPLATE"]["MEMORY"].to_i, {}, 'M')
        end

        column :CPU, "Number of CPUs", :size=>3 do |d|
            d["VM"]["TEMPLATE"]["CPU"]
        end

        column :NET_RX, "Data received from the network", :size=>6 do |d|
            # NET is measured in bytes, unit_to_str expects KBytes
            OpenNebulaHelper.unit_to_str(d["VM"]["NET_RX"].to_i / 1024.0, {})
        end

        column :NET_TX, "Data sent to the network", :size=>6 do |d|
            # NET is measured in bytes, unit_to_str expects KBytes
            OpenNebulaHelper.unit_to_str(d["VM"]["NET_TX"].to_i / 1024.0, {})
        end

        default :VID, :HOSTNAME, :REASON, :START_TIME, :END_TIME, :MEMORY, :CPU, :NET_RX, :NET_TX
    end

    def self.print_start_enc_time_header(start_time, end_time)
        print "Showing active history records from "

        CLIHelper.scr_bold
        if ( start_time != -1 )
            print Time.at(start_time).to_s
        else
            print "-"
        end

        CLIHelper.scr_restore
        print " to "

        CLIHelper.scr_bold
        if ( end_time != -1 )
            print Time.at(end_time).to_s
        else
            print "-"
        end

        CLIHelper.scr_restore
        puts
        puts
    end

    def self.print_user_header(user_id)
        CLIHelper.scr_bold
        CLIHelper.scr_underline
        puts "# User #{user_id}".ljust(80)
        CLIHelper.scr_restore
        puts
    end
end