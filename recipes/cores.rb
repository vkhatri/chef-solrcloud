#
# Cookbook Name:: solrcloud
# Recipe:: cores
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

node.solrcloud.cores.each { |core_name, core_options|

  Chef::Application.fatal!("#{core_name} is missing :name key. :name key is required to create a core name") if not core_options[:name]

  case core_options[:action]
  when "remove"
    directory File.join(node.solrcloud.config_sets, core_name) do
      action    :delete
    end

    directory File.join(node.solrcloud.data_dir, core_name) do
      action    :delete
    end
  else
    configset_dir = File.join(node.solrcloud.config_sets, core_name, 'conf')
    directory configset_dir do
      owner     node.solrcloud.user
      group     node.solrcloud.group
      mode      node.solrcloud.dir_mode
     recursive true
    end

    directory File.join(node.solrcloud.data_dir, core_name) do
      owner     node.solrcloud.user
      group     node.solrcloud.group
      mode      node.solrcloud.dir_mode
     recursive true
    end

    template File.join(node.solrcloud.cores_home, core_name, 'core.properties') do
      cookbook  node.solrcloud.cookbook
      source    "core.properties.erb"
      owner     node.solrcloud.user
      group     node.solrcloud.group
      mode      0644
      variables :config => core_options
      notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
    end

    template File.join(configset_dir, 'schema.xml') do
      cookbook  node.solrcloud.cookbook
      source    "#{core_name}.schema.xml.erb"
      owner     node.solrcloud.user
      group     node.solrcloud.group
      mode      0644
      notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
    end

    template File.join(configset_dir, 'solrconfig.xml') do
      cookbook  node.solrcloud.cookbook
      source "#{core_name}.solrconfig.xml.erb"
      owner node.solrcloud.user
      group node.solrcloud.group
      mode  0644
      notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
    end
  end
}

