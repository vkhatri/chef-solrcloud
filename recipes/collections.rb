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

node.solrcloud.collections.each { |collection_name, options|

  Chef::Log.error("collection #{collection_name} is missing option :collection_config_name (zookeeper config set)")

  solrcloud_collection collection_name do
    num_shards      options[:num_shards]
    shards          options[:shards]
    router_field    options[:router_field]
    async           options[:async]
    router_name     options[:router_name]
    router_field    options[:router_field]
    create_node_set         options[:create_node_set]
    replication_factor      options[:replication_factor]
    max_shards_per_node     options[:max_shards_per_node]
    collection_config_name  options[:collection_config_name]
    action          options[:action] 
  end

}

