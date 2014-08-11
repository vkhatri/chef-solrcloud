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

link File.join(node.solrcloud.install_dir, 'webapps', 'solr.war') do
  to      File.join(node.solrcloud.install_dir,'dist',"solr-#{node.solrcloud.version}.war")
  owner   node.solrcloud.user
  group   node.solrcloud.group
  action :create
end

template File.join(node.solrcloud.install_dir, 'resources', 'log4j.properties') do
  source    "log4j.properties.erb"
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0644
  notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

template File.join(node.solrcloud.install_dir, 'contexts', 'solr-jetty-context.xml') do
  source    "solr-jetty-context.xml.erb"
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0644
  notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

template File.join(node.solrcloud.install_dir, 'etc', 'webdefault.xml') do
  source    "webdefault.xml.erb"
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0644
  notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

template File.join(node.solrcloud.install_dir, 'etc', 'jetty.xml') do
  source  "jetty.xml.erb"
  owner   node.solrcloud.user
  group   node.solrcloud.group
  mode    0644
end

template File.join(node.solrcloud.install_dir, 'etc', 'create-solr.keystore.sh') do
  source    "create-solr.keystore.sh.erb"
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0744
  notifies  :run, "execute[generate_key_store_file]", :immediately
end

execute "generate_key_store_file" do
  cwd       File.join(node.solrcloud.install_dir, 'etc')
  command   File.join(node.solrcloud.install_dir, 'etc', 'create-solr.keystore.sh')
  action    :nothing
  notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
  only_if   { node.solrcloud.key_store.manage }
end

cookbook_file  node.solrcloud.key_store.key_store_file_path do
  cookbook  node.solrcloud.key_store.cookbook
  source    node.solrcloud.key_store.key_store_file
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0400
  action    :create
  not_if    { node.solrcloud.key_store.manage  }
end

# May be there is a better way of doing this
if not File.exists? node.solrcloud.key_store.key_store_file_path and node.solrcloud.key_store.manage
  execute "generate_key_store_file" do
    cwd       File.join(node.solrcloud.install_dir, 'etc')
    command   File.join(node.solrcloud.install_dir, 'etc', 'create-solr.keystore.sh')
    notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
    only_if   { node.solrcloud.key_store.manage }
  end
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
  source  "#{node.platform_family}.solr.init.erb"
  owner   node.solrcloud.user
  group   node.solrcloud.group
  mode    0744
end

template node.solrcloud.jmx.access_file do
  source    "jmxremote.access.erb"
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0400
  notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

template node.solrcloud.jmx.password_file do
  source    "jmxremote.password.erb"
  owner     node.solrcloud.user
  group     node.solrcloud.group
  mode      0400
  notifies  :restart, "service[solr]", :delayed if node.solrcloud.notify_restart
end

