#
# Cookbook Name:: solrcloud
# Recipe:: collections
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

node.solrcloud.collections.each { |collection_name, collection_options|
  directory File.join(node.solrcloud.install_dir, collection_name) do
    owner     node.solrcloud.user
    group     node.solrcloud.group
    mode      node.solrcloud.dir_mode
    recursive true
    action    collection_options[:action] || :create
  end

  options[:cores].each { |core_name, core_options|
    directory File.join(node.solrcloud.install_dir, collection_name, core_name) do
      owner     node.solrcloud.user
      group     node.solrcloud.group
      mode      node.solrcloud.dir_mode
      recursive true
      action    core_options[:action] || :create
    end

    template File.join(node.solrcloud.install_dir, collection_name, core_name, 'schema.xml') do
      cookbook  
      source    "#{collection_name}_#{core_name}_#{f}.erb"
      owner     node.solrcloud.user
      group     node.solrcloud.group
      mode      0644
      notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
    end

    template File.join(node.solrcloud.install_dir, collection_name, core_name, 'solrconfig.xml') do
      source "#{collection_name}_#{core_name}_#{f}.erb"
      owner node.solrcloud.user
      group node.solrcloud.group
      mode  0644
      notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
    end
  }
}

service "solr" do
  supports :start => true, :stop => true, :restart => true, :status => true
  service_name node.solrcloud.service_name
  action [:enable, :start]
end
