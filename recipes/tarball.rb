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

Chef::Application.fatal!("attribute node['solrcloud']['cluster_name'] not defined") unless node.solrcloud.cluster_name

# Setup Solr Service User
if node.solrcloud.setup_user
  include_recipe "solrcloud::user"
end

require "tmpdir"

# If running solrCloud, maintain Zookeeper in its own recipe
# Adding Zookeeper cookbook depending upon node.solrcloud.node_type
# include_recipe "zookeeper" if node.solrcloud.node_type == 'cloud_zk'
# Disabling Zookeeper Integration Cookbook for now

temp_d        = Dir.tmpdir
tarball_file  = File.join(temp_d, "solr-#{node.solrcloud.version}.tgz")
tarball_dir   = File.join(temp_d, "solr-#{node.solrcloud.version}")

# Stop Solr Service if running for Version Upgrade
service "solr" do
  service_name node.solrcloud.service_name
  action :stop
  only_if { File.exists? "/etc/init.d/#{node.solrcloud.service_name}" and not File.exists?(node.solrcloud.source_dir) }
end

# Solr Version Package File
remote_file tarball_file do
  source node.solrcloud.tarball.url
  not_if { File.exists?("#{node.solrcloud.source_dir}/dist/solr-#{node.solrcloud.version}.war") }
end

# Extract and Setup Solr Source directories
bash "extract_solr_tarball" do
  user  "root"
  cwd   "/tmp"

  code <<-EOS
    tar xzf #{tarball_file}
    mv --force #{tarball_dir} #{node.solrcloud.source_dir}
    chown -R #{node.solrcloud.user}:#{node.solrcloud.group} #{node.solrcloud.source_dir}
    chmod #{node.solrcloud.dir_mode} #{node.solrcloud.source_dir}
  EOS

  not_if  { File.exists?(node.solrcloud.source_dir) }
  creates "#{node.solrcloud.install_dir}/dist/solr-#{node.solrcloud.version}.war" 
  action  :run
end

# Link Solr install_dir to Current source_dir
link node.solrcloud.install_dir do
  to      node.solrcloud.source_dir
  owner   node.solrcloud.user
  group   node.solrcloud.group
  action  :create
end

# Link Solr lib dir
link File.join(node.solrcloud.install_dir, 'lib') do
  to      File.join(node.solrcloud.source_dir,'example','lib')
  owner   node.solrcloud.user
  group   node.solrcloud.group
  action :create
end

# Link Solr start.jar
link File.join(node.solrcloud.install_dir, 'start.jar') do
  to      File.join(node.solrcloud.source_dir,'example','start.jar')
  owner   node.solrcloud.user
  group   node.solrcloud.group
  action :create
end

# Setup Directories for Solr
[ node.solrcloud.log_dir,
  node.solrcloud.pid_dir,
  node.solrcloud.data_dir,
  node.solrcloud.solr_home,
  node.solrcloud.cores_home,
  node.solrcloud.shared_lib,
  File.join(node.solrcloud.install_dir, 'etc'),
  File.join(node.solrcloud.solr_home, 'configsets')
].each {|dir|
  directory dir do
    owner     node.solrcloud.user
    group     node.solrcloud.group
    mode      0755
    recursive true
    action    :create
  end 
}

# Solr Configuration Files
%w(solr.xml log4j.properties).each do |f|
  template File.join(node.solrcloud.solr_home, f) do
    source "#{f}.erb"
    owner node.solrcloud.user
    group node.solrcloud.group
    mode  0644
    notifies :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
  end
end

# Solr Service User limits
user_ulimit node.solrcloud.user do
  filehandle_limit node.solrcloud.limits.nofile
  process_limit node.solrcloud.limits.nproc
  memory_limit node.solrcloud.limits.memlock
end

ruby_block "require_pam_limits.so" do
  block do
    fe = Chef::Util::FileEdit.new("/etc/pam.d/su")
    fe.search_file_replace_line(/# session    required   pam_limits.so/, "session    required   pam_limits.so")
    fe.write_file
  end
end

# Setup Jetty Config and Solr Service
include_recipe "solrcloud::jetty"

# Setup cores - node.solrcloud.cores
include_recipe "solrcloud::cores"

service "solr" do
  supports :start => true, :stop => true, :restart => true, :status => true
  service_name node.solrcloud.service_name
  action [:enable, :start]
end
