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
    class VcVappCreate < Chef::Knife
      include Knife::VcCommon

      deps do
        require 'chef/json_compat'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end


      banner "knife vc vapp create [VDC_ID] [NAME] [DESCRIPTION] [TEMPLATE_ID] (options)"

      option :run_list,
        :short => "-r RUN_LIST",
        :long => "--run-list RUN_LIST",
        :description => "Comma separated list of roles/recipes to apply",
        :proc => lambda { |o| o.split(/[\s,]+/) },
        :default => []

      option :distro,
        :short => "-d DISTRO",
        :long => "--distro DISTRO",
        :description => "Bootstrap a distro using a template; default is 'ubuntu10.04-gems'",
        :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
        :default => "ubuntu10.04-gems"

      option :template_file,
        :long => "--template-file TEMPLATE",
        :description => "Full path to location of template to use",
        :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
        :default => false

      option :chef_node_name,
        :short => "-N NAME",
        :long => "--node-name NAME",
        :description => "The Chef node name for your new node",
        :proc => Proc.new { |t| Chef::Config[:knife][:chef_node_name] = t }

      option :image,
        :short => "-I IMAGE_ID",
        :long => "--vcloud-image IMAGE_ID",
        :description => "Your VCloud virtual app template/image name",
        :proc => Proc.new { |template| Chef::Config[:knife][:image] = template }

      option :vcpus,
        :long => "--vcpus VCPUS",
        :description => "Defines the number of vCPUS per VM. Possible values are 1,2,4,8",
        :proc => Proc.new { |vcpu| Chef::Config[:knife][:vcpus] = vcpu }

      option :memory,
        :short => "-m MEMORY",
        :long => "--memory MEMORY",
        :description => "Defines the number of MB of memory. Possible values are 512,1024,1536,2048,4096,8192,12288 or 16384.",
        :proc => Proc.new { |memory| Chef::Config[:knife][:memory] = memory }

      option :ssh_password,
        :long => "--ssh-password PASSWORD",
        :description => "SSH Password for the user",
        :proc => Proc.new { |password| Chef::Config[:knife][:ssh_password] = password }

      option :no_bootstrap,
        :long => "--no-bootstrap",
        :description => "Disable Chef bootstrap",
        :boolean => true,
        :proc => Proc.new { |v| Chef::Config[:knife][:no_bootstrap] = v },
        :default => false

      option :bootstrap_protocol,
        :long => "--bootstrap-protocol protocol",
        :description => "Protocol to bootstrap windows servers. options: winrm",
        :default => nil

      option :bootstrap_proxy,
        :long => "--bootstrap-proxy PROXY_URL",
        :description => "The proxy server for the node being bootstrapped",
        :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_proxy] = v }

      option :vdc_id,
        :long => "--vdc_id VDC_ID",
        :description => "UUID of VDC",
        :default => nil

      option :description,
        :long => "--description NODE_DESCRIPTION",
        :description => "Describe Node",
        :default => nil

      ###Network Options###

      option :network_name,
             :long => "--network_name NETWORK_ID",
             :description => "vCloud vOrg network",
             :default => nil

      option :network2_name,
             :long => "--network2_name NETWORK_ID",
             :description => "vCloud vOrg network",
             :default => nil

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


      option :fence_mode,
             :long => "--fence_mode BRIDGED",
             :description => "Set mode bridge or isolated (default bridged)",
             :default => 'bridged'

      def run
        $stdout.sync = true

        vdc_id = locate_config_value(:vdc_id)
        name = locate_config_value(:chef_node_name)
        description = locate_config_value(:description)
        templateId = locate_config_value(:image)

        config = {
          :name => locate_config_value(:network_name),
          :name_net2 => locate_config_value(:network2_name),
          :fence_mode => locate_config_value(:fence_mode),
          :retain_net => locate_config_value(:retain_net),
          :fence2_mode => locate_config_value(:fence2_mode),
          :retain2_net => locate_config_value(:retain2_net)
        }
        puts config.to_json

        connection.login

        vapp_ids = connection.create_vapp_from_template vdc_id, name, description, templateId, config
        puts vapp_ids.inspect
        
        task_id = vapp_ids[:task_id]
        vapp_id = vapp_ids[:vapp_id]

        print "vApp creation..."
        wait_task(connection, task_id)
        
        puts "vApp created with ID: #{ui.color(vapp_id, :cyan)}"

        vapp_info = connection.get_vapp vapp_id

         
        vms_info = vapp_info[:vms_hash]
        puts vms_info
        puts "you reached point 1"
        
      #Power off vapp to configure network
        print "Stopping vApp ..."
        task_id = connection.poweroff_vapp vapp_id
        wait_task(connection, task_id)
        puts "vApp Stopped!"  


        
      #Start Configuring Network 
      #Get vm id
      vm_id = nil
      vapp_info[:vms_hash].each do |k,v|
         vm_id =  v[:id]
      end  
      puts "after #{vm_id}" 
       
     
        puts "Starting Network Configuration..."
        network_name =  locate_config_value(:network_name)
        puts network_name
        network2_name = locate_config_value(:network2_name)
        puts network2_name
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



       #Change vm name
       computer_name = locate_config_value(:chef_node_name)
       task_id, response = connection.set_vm_guest_customization vm_id, computer_name, config
        
       print "Change VM Name to #{computer_name}..."
        wait_task(connection, task_id)
     
      #Power ON vapp
        print "Starting vApp ..."
        task_id = connection.poweron_vapp vapp_id
        wait_task(connection, task_id)
        puts "vApp Started"
 
      #Getting ready to Bootstrap
       puts "waiting for ip..."
       
       ips = connection.get_vapp vapp_id
       puts ips[:ip1]
      
      
     #Wait for ip address to populate 
       max_count = 200
       while ips[:ip1] == nil do
          ips = connection.get_vapp vapp_id
          puts ips
        if (max_count -= 1) <= 0
          puts max_count
          raise RuntimeError, "Failed to get IP after #{max_count} tries " +
          "for #{vapp_id}. Please use knife vc vapp show #{vapp_id}", caller
        end
      end
       puts bootip = ips[:ip1]
       puts ips[:ip2]

      
      if locate_config_value(:no_bootstrap) == false
        sleep 20
        bootstrap_for_node(name, bootip).run
      end

        connection.logout
      end
         
   def bootstrap_for_node(name, bootip)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = bootip
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:ssh_user] = config[:ssh_user]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = config[:chef_node_name] || vm.name
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro)
        # bootstrap will run as root...sudo (by default) also messes up Ohai on CentOS boxes
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = config[:environment]
        bootstrap.config[:no_host_key_verify] = config[:no_host_key_verify]
        bootstrap.config[:ssh_password] = config[:ssh_password]
        bootstrap.config[:first_boot_attributes] = locate_config_value(:json_attributes) || {}
        bootstrap
      end
    end
  end
end
