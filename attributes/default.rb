default[:solrcloud] = {
  :user         => 'solr',
  :group        => 'solr',
  :user_home    => nil,
  :setup_user   => true, # ideally it must be set to false for Production environment and advised to manage solr user via different cookbook

  :version      => '4.9.0',

  :install_dir  => '/usr/local/solr',
  :data_dir     => '/opt/solr',

  :notify_restart   => false, # notify service restart on config change
  :service_name     => 'solr',
  :service_start_wait   => 15,

  :dir_mode     => '0755', # default directory permissions used by solrcloud cookbook
  :pid_dir      => '/var/run/solr', # solr service user pid dir
  :log_dir      => '/var/log/solr',

  :port         => 8983,
  :ssl_port     => 8984,

  :enable_ssl   => true,
  :enable_request_log   => true,
  :enable_jmx   => true,
  :manage_zkconfigsets          => false, # manage zookeeper configSet, it is recommended to enable this attribute only on one node,
                                          # Otherwise, each new node or configSet update will reupload config to zookeeper
  :manage_zkconfigsets_source   => true,  # manage solr configSet source
  :notify_zkconfigsets_upload   => true,  # notify triggers configSet upload to zookeeper, must be enabled only on one or limited set of nodes
  :manage_collections           => false, # manage solr collections, it is recommended to enable this attribute only on one node if possible.
                                          # Setting this attribute to all the nodes could lead to cluster wide issue. Issues encountered
                                          # after creating a collection could lead to multiple replica set for a collection on one node.
                                          # Use it wisely.

  :java_options => [],

  :jmx          => {
    :port       => 1099,
    :ssl        => false, # Currently not managed
    :authenticate   => false,
    :users      => {
      :solrmonitor  => {
        :access     => 'readonly',
        :password   => 'solrmonitor',
        :action     => 'create'
      },
      :solrcontrol  => {
        :access     => 'readwrite',
        :password   => 'solrcontrol'
      }
    },
  },

  :jetty_config => {
    :server     => {
      :min_threads    => 10,
      :max_threads    => 10000,
      :detailed_dump  => 'false'
    },
    :connector        => { # Default Parameters for org.eclipse.jetty.server.bio.SocketConnector
      :stats_on       => 'true',
      :max_idle_time  =>  50000,
      :low_resource_max_idle_time   => 1500
    },
    :ssl_connector        => {
      :need_client_auth   => 'false',
      :max_idle_time      =>  30000
    }
  },

  :key_store    => {
    :cookbook           => 'solrcloud',
    :key_store_file     => 'solr.keystore',
    :key_store_password => 'secret',

    :manage     => true, # if set false, cookbook will look for 'node.solrcloud.jetty_config.ssl_connector.key_store_file' file in cookbook/files/solr.keystore
    :key_algo   => 'RSA',
    :cn         => 'localhost',
    :ou         => 'ApacheSolrCloudTest',
    :o          => 'lucene.apache.org',
    :c          => 'US',
    :ext        => 'san=ip:127.0.0.1',
    :validity   => 999999
  },

  :request_log  => {
    :retain_days  => 10,
    :log_cookies  => 'false',
    :time_zone    => 'UTC'
  },

  :template_cookbook        => "solrcloud", # template source cookbook
  :zkconfigsets_cookbook    => "solrcloud", # cores configuration source cookbook, it is better to have a separate cores cookbook

  :zk_run       => false, # start solr with zookeeper, useful for testing purpose
  :zk_run_port  => 2181, # start solr with zookeeper, useful for testing purpose

  :collections  => {}, # solr collections

  :zkconfigsets => {}, # solr zookeeper configSets

  :hdfs         => {
    :enable             => false,
    :directory_factory  => 'HdfsDirectoryFactory',
    :lock_type          => 'hdfs',
    :hdfs_home          => nil # syntax: 'hdfs://host:port/path'
  },

  :limits => {
    :memlock    => 'unlimited',
    :nofile     => 48000,
    :nproc      => 'unlimited'
  },

    # log4j.properties config
  :log4j        => {
    :level              => 'INFO',
    :console            => false,
    :max_file_size      => '100MB',
    :max_backup_index   => '10',
    :conversion_pattern => '%d{ISO8601} [%t] %-5p %c{3} %x - %m%n'
  },

  :solr_config       => {
    :admin_handler        => 'org.apache.solr.handler.admin.CoreAdminHandler',
    :admin_path           => '/solr/admin',
    :core_load_threads    => 3,
    :management_path      => nil,
    :share_schema         => 'false',
    :transient_cache_size => 1000000,
    :solrcloud  => {
      :host_context       => 'solr',
      :distrib_update_conn_timeout    => 1000000,
      :distrib_update_so_timeout      => 1000000,
      :leader_vote_wait   => 1000000,
      :zk_client_timeout  => 15000,
      :zk_host            => [], # Syntax: ["zkHost:zkPort"]
      :generic_core_node_names        => 'true'
    },
    :shard_handler_factory  => {
      :socket_timeout       => 0,
      :conn_timeout         => 0
    },
    :logging          => {
      :enabled        => 'true',
      :logging_class  => nil,
      :watcher        => {
        :logging_size => 1000,
        :threshold    => 'INFO'
      }
    }
  }

}

# Solr Directories
default[:solrcloud][:solr_home]   = File.join(node.solrcloud.install_dir,'solr')
default[:solrcloud][:cores_home]  = File.join(node.solrcloud.solr_home, 'cores/')
default[:solrcloud][:shared_lib]  = File.join(node.solrcloud.install_dir,'lib')

# Solr default configSets directory
default[:solrcloud][:config_sets] = File.join(node.solrcloud.solr_home,'configsets')

default[:solrcloud][:zk_run_data_dir]  = File.join(node.solrcloud.install_dir,'zookeeperdata')

# Set zkHost for zookeeper configSet management
default[:solrcloud][:solr_config][:solrcloud][:zk_host] = ["#{node.ipaddress}:#{node.solrcloud.zk_run_port}"] if node.solrcloud.zk_run

# Solr Zookeeper configSets directory (collection.configName)
default[:solrcloud][:zkconfigsets_home] = File.join(node.solrcloud.install_dir,'zkconfigs')

default[:solrcloud][:solr_config][:core_root_directory]     = node.solrcloud.cores_home
default[:solrcloud][:solr_config][:shared_lib]              = node.solrcloud.shared_lib
default[:solrcloud][:solr_config][:solrcloud][:host_port]   = node.solrcloud.port


default[:solrcloud][:source_dir]      = "/usr/local/solr-#{node.solrcloud.version}"
default[:solrcloud][:tarball][:url]   = "https://archive.apache.org/dist/lucene/solr/#{node.solrcloud.version}/solr-#{node.solrcloud.version}.tgz"
default[:solrcloud][:tarball][:md5]   = '316f11ed8e81cf07ebfa6ad9443add09'

default[:solrcloud][:key_store][:key_store_file_path]      = File.join(node.solrcloud.install_dir, 'etc', node.solrcloud.key_store.key_store_file)

default[:solrcloud][:jmx][:password_file]         = File.join(node.solrcloud.install_dir, 'resources', 'jmxremote.password')
default[:solrcloud][:jmx][:access_file]           = File.join(node.solrcloud.install_dir, 'resources', 'jmxremote.access')

