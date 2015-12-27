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

solr_etc_dir = ::File.join(node['solrcloud']['install_dir'], 'etc')

link ::File.join(node['solrcloud']['install_dir'], 'webapps', 'solr.war') do
  to ::File.join(node['solrcloud']['install_dir'], node['solrcloud']['server_base_dir_name'], 'webapps', 'solr.war')
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
  action :create
end

template ::File.join(node['solrcloud']['install_dir'], 'resources', 'log4j.properties') do
  source 'log4j.properties.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template ::File.join(node['solrcloud']['install_dir'], 'contexts', 'solr-jetty-context.xml') do
  source 'solr-jetty-context.xml.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template ::File.join(solr_etc_dir, 'webdefault.xml') do
  source 'webdefault.xml.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template ::File.join(solr_etc_dir, 'jetty.xml') do
  source 'jetty.xml.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template ::File.join(solr_etc_dir, 'create-solr.keystore.sh') do
  source 'create-solr.keystore.sh.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0744
  notifies :run, 'execute[generate_key_store_file_on_notify]', :immediately
end

execute 'generate_key_store_file_on_notify' do
  cwd solr_etc_dir
  command ::File.join(solr_etc_dir, 'create-solr.keystore.sh')
  action :nothing
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
  only_if { node['solrcloud']['key_store']['manage'] }
end

cookbook_file 'solr.keystore' do
  path node['solrcloud']['key_store']['key_store_file_path']
  cookbook node['solrcloud']['key_store']['cookbook']
  source node['solrcloud']['key_store']['key_store_file']
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0400
  not_if { node['solrcloud']['key_store']['manage'] }
end

# May be there is a better way of doing this
if !File.exist?(node['solrcloud']['key_store']['key_store_file_path']) && node['solrcloud']['key_store']['manage']
  execute 'generate_key_store_file' do
    cwd solr_etc_dir
    command ::File.join(solr_etc_dir, 'create-solr.keystore.sh')
    notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
    only_if { node['solrcloud']['key_store']['manage'] }
  end
end

template node['solrcloud']['jmx']['access_file'] do
  source 'jmxremote.access.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0400
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template node['solrcloud']['jmx']['password_file'] do
  source 'jmxremote.password.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0400
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end
