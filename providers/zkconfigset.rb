#
# Cookbook Name:: solrcloud
# Provider:: zkconfigset
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

use_inline_resources

action :delete do
  converge_by("delete config set #{new_resource.configset_name} if exists \n") do
    execute "zk_config_set_rmr_#{new_resource.configset_name}" do
      command "echo 'rmr /configs/#{new_resource.configset_name}' | #{new_resource.zkcli} -server #{new_resource.zkhost} 2>&1"
      only_if { new_resource.manage_zkconfigsets && SolrCloud::Zk.new(new_resource.zkhost).configset?(new_resource.configset_name) }
    end

    directory ::File.join(new_resource.zkconfigsets_home, new_resource.configset_name) do
      recursive true
      action :delete
      only_if { node['solrcloud']['manage_zkconfigsets_source'] }
    end
  end
end

action :create do
  converge_by("create config set #{new_resource.configset_name} if missing \n") do
    remote_directory ::File.join(new_resource.zkconfigsets_home, new_resource.configset_name) do
      cookbook new_resource.zkconfigsets_cookbook
      source new_resource.configset_name
      owner new_resource.user
      group new_resource.group
      mode 0644
      files_mode 0644
      files_owner new_resource.user
      files_group new_resource.group
      notifies :run, "execute[zk_config_set_upconfig_#{new_resource.configset_name}_update_upload]", :immediately if node['solrcloud']['notify_zkconfigsets_upload']
      only_if { node['solrcloud']['manage_zkconfigsets_source'] }
    end

    # Upload on any config update
    execute "zk_config_set_upconfig_#{new_resource.configset_name}_update_upload" do
      command "#{new_resource.solr_zkcli} -zkhost #{new_resource.zkhost} -cmd upconfig -confdir #{::File.join(new_resource.zkconfigsets_home, new_resource.configset_name, 'conf')} -confname #{new_resource.configset_name} 2>&1"
      action :nothing
      only_if { node['solrcloud']['manage_zkconfigsets'] }
    end

    # Update if config is not present in zk, like attribute node['solrcloud']['manage_zkconfigsets'] was not during the first chef run
    execute "zk_config_set_upconfig_#{new_resource.configset_name}_missing_upload" do
      command "#{new_resource.solr_zkcli} -zkhost #{new_resource.zkhost} -cmd upconfig -confdir #{::File.join(new_resource.zkconfigsets_home, new_resource.configset_name, 'conf')} -confname #{new_resource.configset_name} 2>&1"
      action :run
      only_if { node['solrcloud']['manage_zkconfigsets'] && (new_resource.force_upload || !SolrCloud::Zk.new(new_resource.zkhost).configset?(new_resource.configset_name)) }
    end
  end
end
