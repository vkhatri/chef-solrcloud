
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

define  :solrcloud_collection do
=begin
        :num_shards     => 1,
        :shards         => nil,
        :router_field   => nil,
        :async          => nil,
        :router_name    => nil,
        :router_field   => nil,
        :action         => 'create',
        :host           => 'localhost',
        :port           => '8983',
        :collection_config_name   => nil,
        :create_node_set          => nil,
        :max_shards_per_node      => nil,      
        :replication_factor       => 1 do
=end
  #Chef::Resource::User.send(:include, SolrCloud::Helper)
  #Chef::Recipe.send(:include, SolrCloud)

  Chef::Log.error("collection #{params[:name]} is missing :collection_config_name") if not params[:collection_config_name] and params[:action] == 'create'
  Chef::Recipe::SolrCloud.setup_collection params
end
