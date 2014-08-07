default[:solrcloud] = {
  :configset_manager  => false, # set it true for node to manage zookeeper configuration
  :user         => 'solr',
  :group        => 'solr',
  :user_home    => nil,
  :setup_user   => true, # ideally it must be set to false for Production environment and advised to manage solr user via different cookbook
  :version      => '4.9.0',
  :install_dir  => '/usr/local/solr',
  :data_dir     => '/opt/solr',
  :notify_restart   => false, # notify service restart on config change 
  :service_name     => 'solr', 
  :dir_mode     => '0755', # default directory permissions used by solrcloud cookbook
  :pid_dir      => '/var/run/solr', # solr service user pid dir
  :log_dir      => '/var/log/solr',
  :cookbook     => "solrcloud", # template source cookbook
  :config_sets_cookbook   => "solrcloud", # cores configuration source cookbook, it is better to have a separate cores cookbook
  :collections  => {}, # solr collections 
  :configsets   => {}, # solr zookeeper config sets
  :port         => '8983',

  # Note: This Cookbook does not manage Zookeeper Server/Cluster. 
  # Use Zookeeper Cookbook instead for Zookeeper Cluster Management 
  # Only Setup Zookeeper for Client zkCli.sh.
  #
  :zookeeper    => {
    :version    => '3.4.6'
  },

  :limits => {
    :memlock    => 'unlimited',
    :nofile     => 48000,
    :nproc      => 'unlimited'
  },

    # log4j.properties config
  :log4j        => {
    :MaxFileSize      => '10MB',
    :MaxBackupIndex   => '10'
  },

  :config       => {
    :adminHandler       => 'org.apache.solr.handler.admin.CoreAdminHandler',
    :adminPath          => '/solr/admin',
    :coreLoadThreads    => 3,
    :managementPath     => nil,
    :shareSchema        => 'false',
    :transientCacheSize => 1000000,
    :solrcloud  => {
      :hostContext      => 'solr',
      :distribUpdateConnTimeout   => 1000000,
      :distribUpdateSoTimeout     => 1000000,
      :leaderVoteWait     => 1000000,
      :zkClientTimeout    => 15000,
      :zkHost             => [], # Syntax: ["zkHost:zkPort"]
      :genericCoreNodeNames       => 'true'
    },
    :shardHandlerFactory  => {
      :socketTimeout      => 0,
      :connTimeout        => 0
    },
    :logging          => {
      :enabled        => 'true',
      :loggingClass   => nil,
      :watcher        => {
        :loggingSize  => 1000,
        :threshold    => 'INFO'
      }
    }
  }

}

# Solr Directories
default[:solrcloud][:solr_home]   = File.join(node.solrcloud.install_dir,'solr')
default[:solrcloud][:cores_home]  = File.join(node.solrcloud.solr_home, 'cores/')
default[:solrcloud][:shared_lib]  = File.join(node.solrcloud.install_dir,'lib') 
default[:solrcloud][:config_sets] = File.join(node.solrcloud.solr_home,'configsets')

# Solr Config Sets for Zookeeper (collection.configName)
default[:solrcloud][:config_sets_home] = File.join(node.solrcloud.install_dir,'configs')

default[:solrcloud][:contrib]     = File.join(node.solrcloud.install_dir,'contrib')
default[:solrcloud][:dist]        = File.join(node.solrcloud.install_dir,'dist')

default[:solrcloud][:config][:coreRootDirectory]      = node.solrcloud.cores_home
default[:solrcloud][:config][:sharedLib]              = node.solrcloud.shared_lib
default[:solrcloud][:config][:solrcloud][:hostPort]   = node.solrcloud.port


default[:solrcloud][:source_dir]      = "/usr/local/solr-#{node.solrcloud.version}"
default[:solrcloud][:tarball][:url]   = "https://archive.apache.org/dist/lucene/solr/#{node['solrcloud']['version']}/solr-#{node['solrcloud']['version']}.tgz"
default[:solrcloud][:tarball][:md5]   = '316f11ed8e81cf07ebfa6ad9443add09'

# Zookeeper Client Setup
default[:solrcloud][:zookeeper][:source_dir]      = File.join(node.solrcloud.source_dir, "zookeeper-#{node.solrcloud.zookeeper.version}")
default[:solrcloud][:zookeeper][:install_dir]     = File.join(node.solrcloud.install_dir, 'zookeeper')
default[:solrcloud][:zookeeper][:zkcli]           = File.join(node.solrcloud.zookeeper.install_dir, 'bin', 'zkCli.sh')
default[:solrcloud][:zookeeper][:tarball][:url]   = "https://archive.apache.org/dist/zookeeper/zookeeper-#{node.solrcloud.zookeeper.version}/zookeeper-#{node.solrcloud.zookeeper.version}.tar.gz"
default[:solrcloud][:zookeeper][:tarball][:md5]   = '971c379ba65714fd25dc5fe8f14e9ad1'
default[:solrcloud][:zookeeper][:solr_zkcli]      = "#{node.solrcloud.install_dir}/example/scripts/cloud-scripts/zkcli.sh"

