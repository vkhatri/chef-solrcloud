#
# Cookbook Name:: solrcloud
# Recipe:: config
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

template File.join(node.solrcloud.solr_home, 'solr.xml') do
  source "solr.xml.erb"
  owner node.solrcloud.user
  group node.solrcloud.group
  mode  0644
  notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

template File.join(node.solrcloud.solr_home, 'zoo.cfg') do
  source "zoo.cfg.erb"
  owner node.solrcloud.user
  group node.solrcloud.group
  mode  0644
  notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

