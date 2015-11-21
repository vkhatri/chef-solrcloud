#
# Cookbook Name:: solrcloud
# Recipe:: attributes
#
# Copyright 2015, Virender Khatri
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

node.default['solrcloud']['major_version'] = node['solrcloud']['version'].split('.')[0].to_i
node.default['solrcloud']['minor_version'] = node['solrcloud']['version'].split('.')[1].to_i
node.default['solrcloud']['server_base_dir_name'] = node['solrcloud']['major_version'] == 5 ? 'server' : 'example'

node.default['solrcloud']['source_dir'] = '/usr/local/solr-' + node['solrcloud']['version']

node.default['solrcloud']['jetty_config']['context']['path'] = '/' + node['solrcloud']['context_name']

node.default['solrcloud']['solr_config']['admin_path'] = node['solrcloud']['jetty_config']['context']['path'] + '/admin'

node.default['solrcloud']['solr_config']['solrcloud']['host_context'] = node['solrcloud']['context_name']

# Solr Directories
node.default['solrcloud']['solr_home']   = ::File.join(node['solrcloud']['install_dir'], 'solr')
node.default['solrcloud']['cores_home']  = ::File.join(node['solrcloud']['solr_home'], 'cores/')
node.default['solrcloud']['shared_lib']  = ::File.join(node['solrcloud']['install_dir'], 'lib')

# Solr default configSets directory
node.default['solrcloud']['config_sets'] = ::File.join(node['solrcloud']['solr_home'], 'configsets')

node.default['solrcloud']['zk_run_data_dir'] = ::File.join(node['solrcloud']['install_dir'], 'zookeeperdata')

# Set zkHost for zookeeper configSet management
node.default['solrcloud']['solr_config']['solrcloud']['zk_host'] = ["#{node['ipaddress']}:#{node['solrcloud']['zk_run_port']}"] if node['solrcloud']['zk_run']

node.default['solrcloud']['key_store']['key_store_file_path'] = ::File.join(node['solrcloud']['install_dir'], 'etc', node['solrcloud']['key_store']['key_store_file'])
node.default['solrcloud']['jmx']['password_file']  = ::File.join(node['solrcloud']['install_dir'], 'resources', 'jmxremote.password')
node.default['solrcloud']['jmx']['access_file']    = ::File.join(node['solrcloud']['install_dir'], 'resources', 'jmxremote.access')

node.default['solrcloud']['zookeeper']['source_dir'] = ::File.join(node['solrcloud']['source_dir'], "zookeeper-#{node['solrcloud']['zookeeper']['version']}")
node.default['solrcloud']['zookeeper']['install_dir']      = ::File.join(node['solrcloud']['install_dir'], 'zookeeper')
node.default['solrcloud']['zookeeper']['zkcli']            = ::File.join(node['solrcloud']['zookeeper']['install_dir'], 'bin', 'zkCli.sh')
node.default['solrcloud']['zookeeper']['solr_zkcli']       = ::File.join(node['solrcloud']['install_dir'], node['solrcloud']['server_base_dir_name'], 'scripts/cloud-scripts/zkcli.sh')

if node['solrcloud']['auto_java_memory'] && node['memory'] && node['memory'].key?('total')
  # set heap size to half of total memory if node['solrcloud']['auto_java_memory'] is set
  heap_size = (node['memory']['total'].gsub('kB', '').to_i / 1024).to_i / 2
  heap_size += 1 unless heap_size.even?
  node.default['solrcloud']['java_xmx'] = "#{heap_size}m"
  node.default['solrcloud']['java_xms'] = "#{heap_size}m"
else
  # default heap size
  node.default['solrcloud']['java_xmx'] = '512m'
  node.default['solrcloud']['java_xms'] = '512m'
end
