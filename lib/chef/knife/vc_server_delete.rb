#
# Author:: Stefano Tortarolo (<stefano.tortarolo@gmail.com>)
# Copyright:: Copyright (c) 2012-2013
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Knife
    class VcServerDelete < Chef::Knife
      include Knife::VcCommon

      banner "knife vc server delete [VAPP] (options)"

      def run
        $stdout.sync = true

        vapp_arg = @name_args.shift

        connection.login

        vapp = get_vapp(vapp_arg)
        vapp = vapp[1]
        
       #Power off vapp to configure network
        print "Stopping vApp ..."
        task_id = connection.poweroff_vapp vapp
        wait_task(connection, task_id)
        puts "vApp Stopped!"

        task_id = connection.delete_vapp vapp

        ui.msg "vApp deletion..."
        wait_task(connection, task_id)

        connection.logout
      end
    end
  end
end
