
# Zookeeper Client Setup

# Note: This Cookbook does not manage Zookeeper Server/Cluster.
# Use Zookeeper Cookbook instead for Zookeeper Cluster Management
# Only Setup Zookeeper for Client zkCli.sh.
#

default['solrcloud']['zookeeper']['version']          = '3.4.6'
default['solrcloud']['zookeeper']['source_dir']       = File.join('%{source_dir}', 'zookeeper-%{zk_version}')
default['solrcloud']['zookeeper']['install_dir']      = File.join('%{install_dir}', 'zookeeper')
default['solrcloud']['zookeeper']['zkcli']            = File.join('%{install_dir}', 'bin', 'zkCli.sh')
default['solrcloud']['zookeeper']['tarball']['url']   = 'https://archive.apache.org/dist/zookeeper/zookeeper-%{zk_version}/zookeeper-%{zk_version}.tar.gz'
default['solrcloud']['zookeeper']['tarball']['md5']   = '971c379ba65714fd25dc5fe8f14e9ad1'
default['solrcloud']['zookeeper']['solr_zkcli']       = ::File.join('%{install_dir}', '%{server_base_dir_name}', 'scripts', 'cloud-scripts', 'zkcli.sh')
