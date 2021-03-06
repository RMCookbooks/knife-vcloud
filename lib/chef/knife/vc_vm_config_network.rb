#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/vc_common'

class Chef
  class Knife
    class VcVmConfigNetwork < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vm config network [VM_ID] [NETWORK_NAME] (options)"

      option :vm_net_primary_index,
             :long => "--net-primary NETWORK_PRIMARY_IDX",
             :description => "Index of the primary network interface"

      option :vm_net_index,
             :long => "--net-index NETWORK_IDX",
             :description => "Index of the current network interface"

      option :vm_net_ip,
             :long => "--net-ip NETWORK_IP",
             :description => "IP of the current network interface"

      option :vm_net_is_connected,
             :long => "--net-[no-]connected",
             :description => "Toggle IsConnected flag of the current network interface (default true)",
             :boolean => true,
             :default => true

      option :vm_ip_allocation_mode,
             :long => "--ip-allocation-mode ALLOCATION_MODE",
             :description => "Set IP allocation mode of the current network interface (default POOL)",
             :default => 'POOL'

      option :vm_net_2_index,
             :long => "--net2-index NETWORK_IDX",
             :description => "Index of the current network interface (default 1)",
             :default => '1'

      option :vm_net_2_ip,
             :long => "--net2-ip NETWORK_IP",
             :description => "IP of the current network interface"

      option :vm_net_2_is_connected,
             :long => "--net2-[no-]connected",
             :description => "Toggle IsConnected flag of the current network interface (default true)",
             :boolean => true,
             :default => true

      option :vm_ip_2_allocation_mode,
             :long => "--ip2-allocation-mode ALLOCATION_MODE",
             :description => "Set IP allocation mode of the current network interface (default POOL)",
             :default => 'POOL'


      def run
        $stdout.sync = true

        vm_id = @name_args.shift
        network_name = @name_args.shift
        network2_name = @name_args.shift

        connection.login

        config = {
          :primary_index => locate_config_value(:vm_net_primary_index),
          :network_index => locate_config_value(:vm_net_index),
          :ip => locate_config_value(:vm_net_ip),
          :is_connected => locate_config_value(:vm_net_is_connected),
          :ip_allocation_mode => locate_config_value(:vm_ip_allocation_mode),
          :network_2_index => locate_config_value(:vm_net_2_index),
          :ip_2 => locate_config_value(:vm_net_2_ip),
          :is_2_connected => locate_config_value(:vm_net_2_is_connected),
          :ip_2_allocation_mode => locate_config_value(:vm_ip_2_allocation_mode)
        }

        task_id, response = connection.set_vm_network_config vm_id, network_name, network2_name, config

        print "VM network configuration..."
        wait_task(connection, task_id)

        connection.logout
      end
    end
  end
end
