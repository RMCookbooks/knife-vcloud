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
    class VcVdcShow < Chef::Knife
      include Knife::VcCommon

      banner "knife vc vdc show [VDC_ID] (options)"

      def run
        $stdout.sync = true

        vdc_id = @name_args.first

        connection.login

        header = [
            ui.color('Name', :bold),
            ui.color('ID', :bold),
            ui.color('Status', :bold),
            ui.color('IP', :bold),
        ]

        vdc = connection.get_vdc vdc_id
        puts net = vdc[:networks]
             puts net["DB"]
             puts net ["APP"]

        puts "#{ui.color('Description:', :cyan)} #{vdc[:description]}"
        list = ["#{ui.color('vAPPS', :cyan)}", '', '', '']
        list << header
        list.flatten!
        vdc[:vapps].each do |k, v, vms_hash|
          vapp = connection.get_vapp v
          list << ("#{k} (#{vms_hash} VMs)" || '')
          list << (v || '')
          list << (vapp[:status] || '')
          list << (vapp[:ip] || '')
        end

        puts ui.list(list, :columns_across, 4)
        connection.logout
      end
    end
  end
end
