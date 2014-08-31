#
# Cookbook Name:: solrcloud
# Resource:: solrcloud_collection
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

actions :create, :delete

default_action :create

attribute :num_shards,    :kind_of => [String, Integer], :default => '1'
attribute :shards,        :kind_of => String, :default => nil
attribute :router_field,  :kind_of => String, :default => nil
attribute :async,         :kind_of => String, :default => nil
attribute :router_name,   :kind_of => String, :default => nil
attribute :router_field,  :kind_of => String, :default => nil
attribute :host,          :kind_of => String, :default => node.ipaddress
attribute :use_ssl,       :kind_of => [TrueClass, FalseClass], :default => false
attribute :port,          :kind_of => [String, Integer], :default => node.solrcloud.port
attribute :ssl_port,      :kind_of => [String, Integer], :default => node.solrcloud.ssl_port
attribute :create_node_set,         :kind_of => String, :default => nil
attribute :replication_factor,      :kind_of => String, :default => 1
attribute :max_shards_per_node,     :kind_of => [String, Integer], :default => nil
attribute :collection_config_name,  :kind_of => String, :default => nil
attribute :zkcli,           :kind_of => String, :default => node.solrcloud.zookeeper.zkcli
attribute :zkhost,          :kind_of => String, :default => node.solrcloud.solr_config.solrcloud.zk_host.first # Need only one node
