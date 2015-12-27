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

# to run apt-get update for first time
include_recipe 'apt' if node['platform'] == 'debian'

# Setup Solr Service User
include_recipe 'solrcloud::user'
include_recipe 'solrcloud::java'

# Require for zk gem
%w(patch gcc make).each do |pkg|
  package pkg do
    action :nothing
    only_if { node['solrcloud']['install_zk_gem'] }
  end.run_action(:install)
end

if Chef::Resource::ChefGem.method_defined?(:compile_time)
  chef_gem 'zk' do
    compile_time true
  end
else
  chef_gem 'zk' do
    action :nothing
    only_if { node['solrcloud']['install_zk_gem'] }
  end.run_action(:install)
end

require 'zk'
require 'net/http'
require 'json'
require 'tmpdir'

solr_version = node['solrcloud']['version']

if node['solrcloud']['tarball_url'] == 'auto'
  tarball_url = "https://archive.apache.org/dist/lucene/solr/#{solr_version}/solr-#{solr_version}.tgz"
else
  tarball_url = node['solrcloud']['tarball_url']
end

tarball_checksum = solr_tarball_sha256sum(solr_version)

temp_dir      = Dir.tmpdir
tarball_file  = ::File.join(temp_dir, "solr-#{solr_version}.tgz")
tarball_dir   = ::File.join(temp_dir, "solr-#{solr_version}")

# Old Source Location for cores backup
if ::File.exist?(node['solrcloud']['install_dir'])
  old_source = ::File.readlink(node['solrcloud']['install_dir'])
  old_source_cores = ::File.join(old_source, 'solr', 'cores')
else
  old_source = nil
end

# Stop Solr Service if running for Version Upgrade
service 'stop_solr' do
  service_name node['solrcloud']['service_name']
  action :stop
  only_if { ::File.exist?("/etc/init.d/#{node['solrcloud']['service_name']}") && !::File.exist?(::File.join(node['solrcloud']['source_dir'], 'dist', "solr-core-#{solr_version}.jar")) }
end

# Solr Version Package File
remote_file 'solr_tarball_file' do
  path tarball_file
  source tarball_url
  checksum tarball_checksum
  not_if { ::File.exist?("#{node['solrcloud']['source_dir']}/dist/solr-core-#{solr_version}.jar") }
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
  creates ::File.join(node['solrcloud']['source_dir'], 'dist', "solr-core-#{solr_version}.jar")
end

# Link Solr install_dir to Current source_dir
link node['solrcloud']['install_dir'] do
  to node['solrcloud']['source_dir']
  notifies :restart, 'service[solr]', :delayed if node['solrcloud']['notify_restart_upgrade']
end

# Link Jetty lib dir
link ::File.join(node['solrcloud']['install_dir'], 'lib') do
  to ::File.join(node['solrcloud']['install_dir'], node['solrcloud']['server_base_dir_name'], 'lib')
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
end

# Link Solr start.jar
link ::File.join(node['solrcloud']['install_dir'], 'start.jar') do
  to ::File.join(node['solrcloud']['install_dir'], node['solrcloud']['server_base_dir_name'], 'start.jar')
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
end

# Setup Directories for Solr
[node['solrcloud']['log_dir'],
 node['solrcloud']['pid_dir'],
 node['solrcloud']['data_dir'],
 node['solrcloud']['solr_home'],
 node['solrcloud']['config_sets'],
 node['solrcloud']['cores_home'],
 node['solrcloud']['zkconfigsets_home'],
 ::File.join(node['solrcloud']['install_dir'], 'etc'),
 ::File.join(node['solrcloud']['install_dir'], 'resources'),
 ::File.join(node['solrcloud']['install_dir'], 'webapps'),
 ::File.join(node['solrcloud']['install_dir'], 'contexts')
].each do |dir|
  directory dir do
    owner node['solrcloud']['user']
    group node['solrcloud']['group']
    mode 0755
    recursive true
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

remote_file 'local_solr_tarball_file' do
  path tarball_file
  action :delete
end

# purge older versions
ruby_block 'purge_old_versions' do
  block do
    require 'fileutils'
    installed_versions = Dir.entries('/usr/local').reject { |a| a !~ /^solr-/ }.sort
    old_versions = installed_versions - ["solr-#{solr_version}"]

    old_versions.each do |v|
      v = "/usr/local/#{v}"
      FileUtils.rm_rf Dir.glob(v)
      Chef::Log.warn("deleted older solr tarball archive #{v}")
    end
  end
  only_if { node['solrcloud']['tarball_purge'] }
end
