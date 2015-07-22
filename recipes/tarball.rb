#
# Cookbook Name:: solrcloud
# Recipe:: tarball
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

# Setup Solr Service User
include_recipe 'solrcloud::user'
include_recipe 'solrcloud::java'

# Require for zk gem
%w(patch gcc).each do |pkg|
  package pkg do
    action :nothing
    only_if { node['solrcloud']['install_zk_gem'] }
  end.run_action(:install)
end

chef_gem 'zk' do
  action :nothing
  only_if { node['solrcloud']['install_zk_gem'] }
end.run_action(:install)

require 'zk'
require 'net/http'
require 'json'
require 'tmpdir'

temp_d        = Dir.tmpdir
tarball_file  = ::File.join(temp_d, "solr-#{node['solrcloud']['version']}.tgz")
tarball_dir   = ::File.join(temp_d, "solr-#{node['solrcloud']['version']}")

# Old Source Location for cores backup
if ::File.exist?(node['solrcloud']['install_dir'])
  old_source = ::File.readlink(node['solrcloud']['install_dir'])
  old_source_cores = ::File.join(old_source, 'solr', 'cores')
else
  old_source = nil
end

# Stop Solr Service if running for Version Upgrade
service 'solr' do
  service_name node['solrcloud']['service_name']
  action :stop
  only_if { File.exist?("/etc/init.d/#{node['solrcloud']['service_name']}") && !File.exist?(node['solrcloud']['source_dir']) }
end

# Solr Version Package File
remote_file tarball_file do
  source node['solrcloud']['tarball']['url']
  not_if { File.exist?("#{node['solrcloud']['source_dir']}/dist/solr-core-#{node['solrcloud']['version']}.jar") }
end

# Extract and Setup Solr Source directories
bash 'extract_solr_tarball' do
  user 'root'
  cwd '/tmp'

  code <<-EOS
    tar xzf #{tarball_file}
    mv --force #{tarball_dir} #{node['solrcloud']['source_dir']}
    chown -R #{node['solrcloud']['user']}:#{node['solrcloud']['group']} #{node['solrcloud']['source_dir']}
    chmod #{node['solrcloud']['dir_mode']} #{node['solrcloud']['source_dir']}
  EOS

  not_if  { File.exist?(node['solrcloud']['source_dir']) }
  creates "#{node['solrcloud']['install_dir']}/dist/solr-core-#{node['solrcloud']['version']}.jar"
  action :run
end

# Link Solr install_dir to Current source_dir
link node['solrcloud']['install_dir'] do
  to node['solrcloud']['source_dir']
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart_upgrade']
  action :create
end

# Link Jetty lib dir
link File.join(node['solrcloud']['install_dir'], 'lib') do
  to File.join(node['solrcloud']['install_dir'], node['solrcloud']['server_base_dir_name'], 'lib')
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  action :create
end

# Link Solr start.jar
link File.join(node['solrcloud']['install_dir'], 'start.jar') do
  to File.join(node['solrcloud']['install_dir'], node['solrcloud']['server_base_dir_name'], 'start.jar')
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  action :create
end

# Setup Directories for Solr
[node['solrcloud']['log_dir'],
 node['solrcloud']['pid_dir'],
 node['solrcloud']['data_dir'],
 node['solrcloud']['solr_home'],
 node['solrcloud']['config_sets'],
 node['solrcloud']['cores_home'],
 node['solrcloud']['zkconfigsets_home'],
 File.join(node['solrcloud']['install_dir'], 'etc'),
 File.join(node['solrcloud']['install_dir'], 'resources'),
 File.join(node['solrcloud']['install_dir'], 'webapps'),
 File.join(node['solrcloud']['install_dir'], 'contexts')
].each do |dir|
  directory dir do
    owner node['solrcloud']['user']
    group node['solrcloud']['group']
    mode 0755
    recursive true
    action :create
  end
end

# Restore Cores after upgrade
ruby_block 'backup_solr_cores' do
  block do
    require 'fileutils'
    Chef::Log.info("Removing Existing Cores under location - #{node['solrcloud']['cores_home']}")
    # Remove existing cors if any
    FileUtils.remove_dir(::File.join(node['solrcloud']['cores_home'], '.'), :verbose => true)
    Chef::Log.info("Restoring Cores #{old_source} -> #{node['solrcloud']['cores_home']}")
    # Copy old source cores to new source cores
    FileUtils.cp_r(::File.join(old_source_cores, '.'), node['solrcloud']['cores_home'], :verbose => true)
  end
  only_if { node['solrcloud']['restore_cores'] && old_source && old_source != node['solrcloud']['source_dir'] }
end

directory node['solrcloud']['zk_run_data_dir'] do
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0755
  recursive true
  action :create
  only_if { node['solrcloud']['zk_run'] }
end

# Solr Service User limits
user_ulimit node['solrcloud']['user'] do
  filehandle_limit node['solrcloud']['limits']['nofile']
  process_limit node['solrcloud']['limits']['nproc']
  memory_limit node['solrcloud']['limits']['memlock']
end

ruby_block 'require_pam_limits.so' do
  block do
    fe = Chef::Util::FileEdit.new('/etc/pam.d/su')
    fe.search_file_replace_line(/# session    required   pam_limits.so/, 'session    required   pam_limits.so')
    fe.write_file
  end
end

# Solr Config
include_recipe 'solrcloud::config'

# Jetty Config
include_recipe 'solrcloud::jetty'

# Zookeeper Client Setup
include_recipe 'solrcloud::zkcli'

service 'solr' do
  supports :start => true, :stop => true, :restart => true, :status => true
  service_name node['solrcloud']['service_name']
  action [:enable, :start]
  notifies :run, 'ruby_block[wait_start_up]', :immediately
end

# Waiting for Service
ruby_block 'wait_start_up' do
  block  do
    sleep node['solrcloud']['service_start_wait']
  end
  action :nothing
end

remote_file tarball_file do
  action :delete
end

# Setup configsets - node['solrcloud']['zkconfigsets']
include_recipe 'solrcloud::zkconfigsets'

# Setup collections - node['solrcloud']['collections']
include_recipe 'solrcloud::collections'
