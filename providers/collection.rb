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
  false
end

action :create do

  if node.solrcloud.manage_collections
    if whyrun_mode?
      converge_by("create solr collection #{new_resource.name}") do
      end
    else
      Chef::Log.error("collection #{new_resource.name} is missing option :collection_config_name (zookeeper configSet)") if not new_resource.collection_config_name
      obj = SolrCloud::SolrCollection.new(:num_shards     => new_resource.num_shards,
                                          :shards         => new_resource.shards,
                                          :name           => new_resource.name,
                                          :router_field   => new_resource.router_field,
                                          :async          => new_resource.async,
                                          :router_name    => new_resource.router_name,
                                          :router_field   => new_resource.router_field,
                                          :host           => new_resource.host,
                                          :port           => new_resource.port,
                                          :ssl            => new_resource.ssl,
                                          :ssl_port       => new_resource.ssl_port,
                                          :action         => 'create',
                                          :create_node_set        => new_resource.create_node_set,
                                          :replication_factor     => new_resource.replication_factor,
                                          :max_shards_per_node    => new_resource.max_shards_per_node,
                                          :collection_config_name => new_resource.collection_config_name
                                         )
      if obj.collection? new_resource.name
        Chef::Log.info("solr collection #{new_resource.name} already exists")
      else
        new_resource.updated_by_last_action(true) if obj.create_collection
      end
    end
  end

end

action :delete do

  if node.solrcloud.manage_collections
    if whyrun_mode
      converge_by("delete solr collection #{new_resource.name}") do
      end
    else
      obj = SolrCloud::SolrCollection.new(:name           => new_resource.name,
                                          :host           => new_resource.host,
                                          :port           => new_resource.port,
                                          :ssl            => new_resource.ssl,
                                          :ssl_port       => new_resource.ssl_port,
                                          :action         => 'delete'
                                         )
      if obj.collection? new_resource.name
        new_resource.updated_by_last_action(true) if obj.delete_collection
      else
        Chef::Log.info("solr collection #{new_resource.name} does not exists")
      end

    end
  end

end

