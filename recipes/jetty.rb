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

major_version = node['solrcloud']['major_version'] || node['solrcloud']['version'].split('.')[0].to_i
server_base_dir_name = node['solrcloud']['server_base_dir_name'] || major_version == 5 ? 'server' : 'example'
link File.join(node['solrcloud']['install_dir'], 'webapps', 'solr.war') do
  to File.join(node['solrcloud']['install_dir'], server_base_dir_name, 'webapps', 'solr.war')
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
  action :create
end

template File.join(node['solrcloud']['install_dir'], 'resources', 'log4j.properties') do
  source 'log4j.properties.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template File.join(node['solrcloud']['install_dir'], 'contexts', 'solr-jetty-context.xml') do
  source 'solr-jetty-context.xml.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template File.join(node['solrcloud']['install_dir'], 'etc', 'webdefault.xml') do
  source 'webdefault.xml.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template File.join(node['solrcloud']['install_dir'], 'etc', 'jetty.xml') do
  source 'jetty.xml.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template File.join(node['solrcloud']['install_dir'], 'etc', 'create-solr.keystore.sh') do
  source 'create-solr.keystore.sh.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0744
  notifies :run, 'execute[generate_key_store_file]', :immediately
end

execute 'generate_key_store_file' do
  cwd File.join(node['solrcloud']['install_dir'], 'etc')
  command File.join(node['solrcloud']['install_dir'], 'etc', 'create-solr.keystore.sh')
  action :nothing
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
  only_if { node['solrcloud']['key_store']['manage'] }
end

key_store_file_path = node['solrcloud']['key_store']['key_store_file_path'] % {
  install_dir: node['solrcloud']['install_dir'],
  key_store_file: node['solrcloud']['key_store']['key_store_file']
}

cookbook_file key_store_file_path do
  cookbook node['solrcloud']['key_store']['cookbook']
  source node['solrcloud']['key_store']['key_store_file']
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0400
  action :create
  not_if { node['solrcloud']['key_store']['manage'] }
end

# May be there is a better way of doing this
if !File.exist?(key_store_file_path) && node['solrcloud']['key_store']['manage']
  execute 'generate_key_store_file' do
    cwd File.join(node['solrcloud']['install_dir'], 'etc')
    command File.join(node['solrcloud']['install_dir'], 'etc', 'create-solr.keystore.sh')
    notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
    only_if { node['solrcloud']['key_store']['manage'] }
  end
end

java_xmx = node['solrcloud']['java_xmx']
java_xms = node['solrcloud']['java_xms']

# Calculate -Xmx (Multiple of 1024)
if node['solrcloud']['auto_java_memory'] && node['memory'] && node['memory'].key?('total')
  total_memory = (node['memory']['total'].gsub('kB', '').to_i / 1024).to_i
  total_memory_percentage = (total_memory % 1024)
  system_memory = if total_memory < 2048
                    total_memory / 2
                  else
                    if total_memory_percentage >= node['solrcloud']['auto_system_memory'].to_i
                      total_memory_percentage
                    else
                      total_memory_percentage + 1024
                    end
                  end

  java_memory = total_memory - system_memory
  # Making Java -Xmx even
  java_memory += 1 unless java_memory.even?
  java_xmx = "#{java_memory}m"
  java_xms = "#{java_memory}m"
end

template 'solr_config' do
  source node['solrcloud']['version'] > '5.2' ? 'v5.2.x/solr.conf.erb' : 'solr.conf.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0744
  path node['solrcloud']['sysconfig_file']
  variables(
    java_xmx: java_xmx,
    java_xms: java_xms
  )
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

template '/etc/init.d/solr' do
  source node['solrcloud']['version'] > '5.2' ? 'v5.2.x/solr.init.erb' : "#{node['platform_family']}.solr.init.erb"
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0744
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

access_file = node['solrcloud']['jmx']['access_file'] % { install_dir: node['solrcloud']['install_dir'] }
template access_file do
  source 'jmxremote.access.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0400
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end

password_file = node['solrcloud']['jmx']['password_file'] % { install_dir: node['solrcloud']['install_dir'] }
template password_file do
  source 'jmxremote.password.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0400
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart']
end
