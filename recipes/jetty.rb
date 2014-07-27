#
# Cookbook Name:: solrcloud
# Recipe:: jetty
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

template "/etc/jetty.xml" do
  source "jetty.xml.erb"
  owner node.solrcloud.user
  group node.solrcloud.group
  mode  0644
end

template "solr_config" do
  source  "solr.conf.erb"
  owner   node.solrcloud.user
  group   node.solrcloud.group
  mode    0744
  case node.platform_family
  when 'rhel'
    path  "/etc/sysconfig/solr"
  when 'debian'
    path  "/etc/default/solr"
  end
end

template "/etc/init.d/solr" do
  source "#{node.platform_family}.solr.init.erb"
  owner 'root'
  group 'root'
  mode  0744
end

