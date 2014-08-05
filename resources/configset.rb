# Cookbook Name:: solrcloud
# Resource:: solrcloud_configset
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

attribute :configset_name,  :kind_of => String, :regex => /.*/, :default => :name
attribute :user,            :kind_of => String, :regex => /.*/, :default => node.solrcloud.user
attribute :group,           :kind_of => String, :regex => /.*/, :default => node.solrcloud.group
attribute :skip_zk,         :kind_of => String, :regex => /.*/, :default => false
attribute :zkcli,           :kind_of => String, :regex => /.*/, :default => node.solrcloud.zookeeper.zkcli
attribute :zkhost,          :kind_of => String, :regex => /.*/, :default => node.solrcloud.config.solrcloud.zkHost.first # Need only one node
attribute :configsets_home, :kind_of => String, :regex => /.*/, :default => node.solrcloud.configsets_home
attribute :configsets_cookbook, :kind_of => String, :regex => /.*/, :default => node.solrcloud.configsets_cookbook


