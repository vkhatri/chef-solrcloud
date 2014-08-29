
# Zookeeper Client Setup

# Note: This Cookbook does not manage Zookeeper Server/Cluster.
# Use Zookeeper Cookbook instead for Zookeeper Cluster Management
# Only Setup Zookeeper for Client zkCli.sh.
#

default[:solrcloud][:zookeeper][:version]         = '3.4.6'
default[:solrcloud][:zookeeper][:source_dir]      = File.join(node.solrcloud.source_dir, "zookeeper-#{node.solrcloud.zookeeper.version}")
default[:solrcloud][:zookeeper][:install_dir]     = File.join(node.solrcloud.install_dir, 'zookeeper')
default[:solrcloud][:zookeeper][:zkcli]           = File.join(node.solrcloud.zookeeper.install_dir, 'bin', 'zkCli.sh')
default[:solrcloud][:zookeeper][:tarball][:url]   = "https://archive.apache.org/dist/zookeeper/zookeeper-#{node.solrcloud.zookeeper.version}/zookeeper-#{node.solrcloud.zookeeper.version}.tar.gz"
default[:solrcloud][:zookeeper][:tarball][:md5]   = '971c379ba65714fd25dc5fe8f14e9ad1'
default[:solrcloud][:zookeeper][:solr_zkcli]      = "#{node.solrcloud.install_dir}/example/scripts/cloud-scripts/zkcli.sh"

