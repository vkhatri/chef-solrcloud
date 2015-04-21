#
# Cookbook Name:: solrcloud
# Resource:: solrcloud_zkconfigset
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

attribute :configset_name,  :kind_of => String
attribute :user,            :kind_of => String, :default => node['solrcloud']['user']
attribute :group,           :kind_of => String, :default => node['solrcloud']['group']
attribute :solr_zkcli,      :kind_of => String, :default => node['solrcloud']['zookeeper']['solr_zkcli']
attribute :zkcli,           :kind_of => String, :default => node['solrcloud']['zookeeper']['zkcli']
attribute :zkhost,          :kind_of => String, :default => node['solrcloud']['solr_config']['solrcloud']['zk_host'].first
attribute :zkconfigsets_home,       :kind_of => String, :default => node['solrcloud']['zkconfigsets_home']
attribute :zkconfigsets_cookbook,   :kind_of => String, :default => node['solrcloud']['zkconfigsets_cookbook']
attribute :manage_zkconfigsets,     :kind_of => [FalseClass, TrueClass], :default => node['solrcloud']['manage_zkconfigsets']
attribute :force_upload,     :kind_of => [FalseClass, TrueClass], :default => node['solrcloud']['force_zkconfigsets_upload']

def initialize(*args)
  super
  if @configset_name.nil?
    @configset_name = @name
  end
end
