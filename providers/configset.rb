#
# Cookbook Name:: solrcloud
# Definition:: solrcloud_configset
#
# Copyright 2014, Virender Khatri
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

def whyrun_supported?
  true
end

action :delete do

  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    #converge_by("removing configset #{ @new_resource } from zookeeper #{new_resource.config.solrcloud.zkHost}")
    bash "delete_config_set_#{new_resource.name}" do
      user  "root"
      cwd   "/tmp"
      code <<-EOS
      # #{new_resource.zkcli} -zkhost #{new_resource.zkHost} -cmd downconfig -confdir #{::File.join(new_resource.configsets_home, new_resource.name, 'conf')} -confname #{new_resource.name};
      EOS
      action  :run
      only_if { not new_resource.skip_zk }
    end

    #converge_by("removing configset #{ @new_resource } directory")
    directory ::File.join(new_resource.configsets_home, new_resource.name) do
      action    :delete
    end
  end

end

action :create do

  puts "new_resource.configsets_home=#{new_resource.configsets_home}"

  directory ::File.join(new_resource.configsets_home, new_resource.name) do
    owner       new_resource.user
    group       new_resource.group
    mode        0644
    recursive   true
    action      :create
  end

  remote_directory ::File.join(new_resource.configsets_home, new_resource.name) do
    cookbook    new_resource.configsets_cookbook
    source      new_resource.name
    owner       new_resource.user
    group       new_resource.group
    mode        0644
    files_mode  0644
    files_owner new_resource.user
    files_group new_resource.group
    action      :create
  end

  execute "zk_config_set_upconfig_#{new_resource.name}" do
    command "#{new_resource.zkcli} -zkhost #{new_resource.zkhost} -cmd upconfig -confdir #{::File.join(new_resource.configsets_home, new_resource.name, 'conf')} -confname #{new_resource.name};"
    #not_if { ::File.exists?("/tmp/#{pet_name}")}
  end

=begin
  Chef::Log.info("executing #{new_resource.zkcli} -zkhost #{new_resource.zkcli} -cmd upconfig -confdir #{::File.join(new_resource.configsets_home, new_resource.name, 'conf')} -confname #{new_resource.name};")

  bash "create_config_set_#{new_resource.name}" do
    user  "root"
    cwd   "/tmp"
    code <<-EOS
    #{new_resource.zkcli} -zkhost #{new_resource.zkcli} -cmd upconfig -confdir #{::File.join(new_resource.configsets_home, new_resource.name, 'conf')} -confname #{new_resource.name}
    EOS
    action  :run
    only_if { ::File.exists?(::File.join(new_resource.configsets_home, new_resource.name, 'conf')) and not new_resource.skip_zk }
  end
=end

end

