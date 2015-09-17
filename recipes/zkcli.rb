#
# Cookbook Name:: solrcloud
# Recipe:: zkcli
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
# This recipe DOES NOT configure zookeeper server
# This recipe only setup zookeeper package for zkCli.sh.
#

require 'tmpdir'

zookeeper_tarball_url = "https://archive.apache.org/dist/zookeeper/zookeeper-#{node['solrcloud']['zookeeper']['version']}/zookeeper-#{node['solrcloud']['zookeeper']['version']}.tar.gz"
zookeeper_tarball_checksum   = zookeeper_tarball_sha256sum(node['solrcloud']['zookeeper']['version'])

temp_d        = Dir.tmpdir
tarball_file  = File.join(temp_d, "zookeeper-#{node['solrcloud']['zookeeper']['version']}.tar.gz")
tarball_dir   = File.join(temp_d, "zookeeper-#{node['solrcloud']['zookeeper']['version']}")

# Zookeeper Version Package File
remote_file tarball_file do
  source zookeeper_tarball_url
  checksum zookeeper_tarball_checksum
  not_if { File.exist?("#{node['solrcloud']['zookeeper']['source_dir']}/zookeeper-#{node['solrcloud']['zookeeper']['version']}.jar") }
end

# Extract and Setup Zookeeper Source directories
bash 'extract_zookeeper_tarball' do
  user 'root'
  cwd '/tmp'

  code <<-EOS
    tar xzf #{tarball_file}
    mv --force #{tarball_dir} #{node['solrcloud']['zookeeper']['source_dir']}
    chown -R #{node['solrcloud']['user']}:#{node['solrcloud']['group']} #{node['solrcloud']['zookeeper']['source_dir']}
    chmod #{node['solrcloud']['dir_mode']} #{node['solrcloud']['zookeeper']['source_dir']}
  EOS

  not_if  { File.exist?(node['solrcloud']['zookeeper']['source_dir']) }
  creates "#{node['solrcloud']['zookeeper']['install_dir']}/zookeeper-#{node['solrcloud']['zookeeper']['version']}.jar"
  action :run
end

# Link Solr install_dir to Current source_dir
link node['solrcloud']['zookeeper']['install_dir'] do
  to node['solrcloud']['zookeeper']['source_dir']
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  action :create
end

template File.join(node['solrcloud']['zookeeper']['install_dir'], 'conf', 'zoo.cfg') do
  source 'zoo.cfg.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
end

template File.join(node['solrcloud']['zookeeper']['install_dir'], 'bin', 'zkEnv.sh') do
  source 'zkEnv.sh.erb'
  owner node['solrcloud']['user']
  group node['solrcloud']['group']
  mode 0644
end

remote_file tarball_file do
  action :delete
end
