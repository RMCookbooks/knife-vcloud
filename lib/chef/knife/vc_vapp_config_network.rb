require 'chef/knife/vc_common'

class Chef
  class Knife
    class VcVappConfigNetwork < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vapp config network [VAPP_ID] [NETWORK_NAME] (options)"

      option :vapp_id,
             :long => "--vapp_id VAPP_ID",
             :description => "UUID of VAPP"

      option :network_name,
             :long => "--network_name",
             :description => "NETWORK NAME",
             :default => nil

      option :network_name2,
             :long => "--network_name2",
             :description => "NETWORK NAME of NET 2",
             :default => nil


      option :fence_mode,
             :short => "-F FENCE_MODE",
             :long => "--fence-mode FENCE_MODE",
             :description => "Set Fence Mode (e.g., Isolated, Bridged)",
             :proc => Proc.new { |key| Chef::Config[:knife][:fence_mode] = key }

      option :retain_network,
             :long => "--[no-]retain-network",
             :description => "Toggle Retain Network across deployments (default true)",
             :proc => Proc.new { |key| Chef::Config[:knife][:retain_network] = key },
             :boolean => true,
             :default => true

      option :fence_mode2,
             :long => "--fence-mode2 FENCE_MODE",
             :description => "Set Fence Mode (e.g., Isolated, Bridged)"

      option :retain_network2,
             :long => "--[no-]retain-network2",
             :description => "Toggle Retain Network across deployments (default true)",
             :proc => Proc.new { |key| Chef::Config[:knife][:retain_network2] = key },
             :boolean => true,
             :default => true


      def run
        $stdout.sync = true

        vapp_id = locate_config_value(:vapp_id)
        network_name = locate_config_value(:nework_name)
        network_name2 = locate_config_value(:network_name2)

        connection.login

        config = {
          :fence_mode => locate_config_value(:fence_mode),
          #:parent_network => locate_config_value(:network_name),
          :retain_net => locate_config_value(:retain_net),
          :fence_mode2 => locate_config_value(:fence_mode2),
          #:parent_network2 => locate_config_value(:network_name2),
          :retain_net => locate_config_value(:retain_net2)
        }

        task_id, response = connection.set_vapp_network_config vapp_id, network_name, network_name2, config
        puts response.inspect
        puts task_id

        print "vApp network configuration..."
        puts wait_task(connection, task_id)
        

        connection.logout
      end
    end
  end
end
