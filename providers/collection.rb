#
# Cookbook Name:: solrcloud
# Definition:: solrcloud_collection
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

action :create do
  raise "collection #{new_resource.name} is missing option :collection_config_name (zookeeper configSet)" if not new_resource.collection_config_name

  obj = SolrCloud::SolrCollection.new(:host => new_resource.host, :port => new_resource.port, :use_ssl => new_resource.use_ssl, :ssl_port => new_resource.ssl_port)

  collection_options = {
    :num_shards     => new_resource.num_shards,
    :shards         => new_resource.shards,
    :name           => new_resource.name,
    :router_field   => new_resource.router_field,
    :async          => new_resource.async,
    :router_name    => new_resource.router_name,
    :router_field   => new_resource.router_field,
    :create_node_set        => new_resource.create_node_set,
    :replication_factor     => new_resource.replication_factor,
    :max_shards_per_node    => new_resource.max_shards_per_node,
    :collection_config_name => new_resource.collection_config_name
  }

  # If collection is down for some reason, CREATE API call will simply execute.
  # Checking zookeeper /collections/name makes it more robust.
  #
  # TODO:
  # parse /clusterstate.json for collection existence
  #
  execute "create collection #{new_resource.name}" do
    command   "echo 'creating collection #{new_resource.name} with options #{collection_options.inspect}'"
    notifies  :run, "ruby_block[create collection #{new_resource.name}]", :immediately
    only_if   "echo 'ls /collections/#{new_resource.name}' | #{new_resource.zkcli} -server #{new_resource.zkhost} 2>&1 | egrep -o 'Node does not exist: /collections/#{new_resource.name}' > /dev/null"
  end

  ruby_block "create collection #{new_resource.name}" do
    block do
      obj.create_collection(collection_options)
    end
    only_if { node.solrcloud.manage_collections and not obj.collection?(new_resource.name) }
    action  :nothing
  end
end

action :delete do
  obj = SolrCloud::SolrCollection.new(:host => new_resource.host, :port => new_resource.port, :use_ssl => new_resource.use_ssl, :ssl_port => new_resource.ssl_port)

  ruby_block "delete collection #{new_resource.name}" do
    block do
      obj.delete_collection(new_resource.name)
    end
    only_if { node.solrcloud.manage_collections and obj.collection?(new_resource.name) }
  end
end

