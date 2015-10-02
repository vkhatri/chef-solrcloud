#
# Cookbook Name:: solrcloud
# Recipe:: service
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

template 'solr_config' do
  source node['solrcloud']['version'] > '5.2' ? 'v5.2.x/solr.conf.erb' : 'solr.conf.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0744
  path node['solrcloud']['sysconfig_file']
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template '/etc/init.d/solr' do
  source node['solrcloud']['version'] > '5.2' ? 'v5.2.x/solr.init.erb' : "#{node['platform_family']}.solr.init.erb"
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0744
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

service 'solr' do
  supports :start => true, :stop => true, :restart => true, :status => true
  service_name node['solrcloud']['service_name']
  action [:enable, :start]
  notifies :run, 'ruby_block[wait_start_up]', :immediately
end

# Waiting for Service
ruby_block 'wait_start_up' do
  block do
    sleep node['solrcloud']['service_start_wait']
  end
  action :nothing
end
