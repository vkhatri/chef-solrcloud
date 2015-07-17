
default['solrcloud']['install_zk_gem']  = true
default['solrcloud']['install_java']  = true
default['solrcloud']['user']          = 'solr'
default['solrcloud']['group']         = 'solr'
default['solrcloud']['user_home']     = nil
default['solrcloud']['setup_user']    = true # ideally it must be set to false for Production environment and advised to manage solr user via different cookbook

default['solrcloud']['version']       = '5.1.0'
default['solrcloud']['major_version'] = node['solrcloud']['version'].split('.')[0].to_i
default['solrcloud']['minor_version'] = node['solrcloud']['version'].split('.')[1].to_i
default['solrcloud']['server_base_dir_name'] = node['solrcloud']['major_version'] == 5 ? 'server' : 'example'

default['solrcloud']['install_dir']   = '/usr/local/solr'
default['solrcloud']['data_dir']      = '/opt/solr'

default['solrcloud']['restore_cores'] = true

default['solrcloud']['notify_restart']      = false # notify service restart on config change
default['solrcloud']['notify_restart_upgrade']    = false # notify service restart on config change
default['solrcloud']['service_name']        = 'solr'
default['solrcloud']['service_start_wait']  = 15

default['solrcloud']['dir_mode']      = '0755' # default directory permissions used by solrcloud cookbook
default['solrcloud']['pid_dir']       = '/var/run/solr' # solr service user pid dir
default['solrcloud']['log_dir']       = '/var/log/solr'

default['solrcloud']['port']          = 8983
default['solrcloud']['ssl_port']      = 8984

default['solrcloud']['enable_ssl']    = false
default['solrcloud']['enable_request_log']    = true
default['solrcloud']['enable_jmx']    = true

default['solrcloud']['context_name']  = 'solr' # used to configure the context path for jetty, core admin and solr cloud

# manage zookeeper configSet, it is recommended to enable this attribute only on one node
# Otherwise, each new node or configSet update will reupload config to zookeeper
default['solrcloud']['manage_zkconfigsets']   = false

# manage solr configSet source
default['solrcloud']['manage_zkconfigsets_source']   = true

# notify triggers configSet upload to zookeeper, must be enabled only on one or limited set of nodes
default['solrcloud']['notify_zkconfigsets_upload']   = true

# can be used to force the upload of the configsets (e.g. when it comes not from a cookbook),
# should also only be forced an a limited set of nodes
default['solrcloud']['force_zkconfigsets_upload']    = false

# manage solr collections, it is recommended to enable this attribute only on one node if possible.
# Setting this attribute to all the nodes could lead to cluster wide issue. Issues encountered
# after creating a collection could lead to multiple replica set for a collection on one node.
# Use it with caution.
default['solrcloud']['manage_collections']  = false

# Java Options
default['solrcloud']['java_options']  = []

# JMX Options
default['solrcloud']['jmx']['port']   = 1099
# Currently not managed
default['solrcloud']['jmx']['ssl']    = false
default['solrcloud']['jmx']['authenticate'] = false
# JMX Users
default['solrcloud']['jmx']['users']['solrmonitor']['access']     = 'readonly'
default['solrcloud']['jmx']['users']['solrmonitor']['password']   = 'solrmonitor'
default['solrcloud']['jmx']['users']['solrmonitor']['action']     = 'create'
default['solrcloud']['jmx']['users']['solrcontrol']['access']     = 'readwrite'
default['solrcloud']['jmx']['users']['solrcontrol']['password']   = 'solrcontrol'

# Jetty Server Config
default['solrcloud']['jetty_config']['server']['min_threads']     = 10
default['solrcloud']['jetty_config']['server']['max_threads']     = 10_000
default['solrcloud']['jetty_config']['server']['detailed_dump']   = 'false'

# Jetty Connector Config
# Default Parameters for org.eclipse.jetty.server.bio.SocketConnector
default['solrcloud']['jetty_config']['connector']['stats_on']       = 'true'
default['solrcloud']['jetty_config']['connector']['max_idle_time']  =  50_000
default['solrcloud']['jetty_config']['connector']['low_resource_max_idle_time']   = 1500

# Jetty SSL Connector Config
default['solrcloud']['jetty_config']['ssl_connector']['need_client_auth']   = 'false'
default['solrcloud']['jetty_config']['ssl_connector']['max_idle_time']      =  30_000

# Jetty webapp
default['solrcloud']['jetty_config']['context']['path'] = '/' + node['solrcloud']['context_name']
default['solrcloud']['jetty_config']['context']['temp_directory'] = '/solr-webapp'
default['solrcloud']['jetty_config']['context']['war'] = '/webapps/solr.war'

# Jetty Key Store Config
default['solrcloud']['key_store']['cookbook']   = 'solrcloud'
# if set false, cookbook will look for 'node['solrcloud']['jetty_config.ssl_connector.key_store_file' file in cookbook/files/solr.keystore
default['solrcloud']['key_store']['manage']     = true

default['solrcloud']['key_store']['key_store_file']     = 'solr.keystore'
default['solrcloud']['key_store']['key_store_password'] = 'secret'
default['solrcloud']['key_store']['key_algo']   = 'RSA'
default['solrcloud']['key_store']['cn']         = 'localhost'
default['solrcloud']['key_store']['ou']         = 'ApacheSolrCloudTest'
default['solrcloud']['key_store']['o']          = 'lucene.apache.org'
default['solrcloud']['key_store']['c']          = 'US'
default['solrcloud']['key_store']['ext']        = 'san=ip:127.0.0.1'
default['solrcloud']['key_store']['validity']   = 999_999

# Jetty Request Log
default['solrcloud']['request_log']['retain_days']  = 10
default['solrcloud']['request_log']['log_cookies']  = 'false'
default['solrcloud']['request_log']['time_zone']    = 'UTC'

# template source cookbook
default['solrcloud']['template_cookbook']        = 'solrcloud'

# cores configuration source cookbook, it is better to have a separate cores cookbook
default['solrcloud']['zkconfigsets_cookbook']    = 'solrcloud'

# start solr with zookeeper, useful for testing purpose
default['solrcloud']['zk_run']       = false

# start solr with zookeeper, useful for testing purpose
default['solrcloud']['zk_run_port']  = 2181

# solr collections
default['solrcloud']['collections']  = {}

# solr zookeeper configSets
default['solrcloud']['zkconfigsets'] = {}

# solr hdfs options
default['solrcloud']['hdfs']['enable']             = false
default['solrcloud']['hdfs']['directory_factory']  = 'HdfsDirectoryFactory'
default['solrcloud']['hdfs']['lock_type']          = 'hdfs'
default['solrcloud']['hdfs']['hdfs_home']          = nil # syntax: 'hdfs://host:port/path'

# solr process limits
default['solrcloud']['limits']['memlock']    = 'unlimited'
default['solrcloud']['limits']['nofile']     = 48_000
default['solrcloud']['limits']['nproc']      = 'unlimited'

# log4j.properties config
default['solrcloud']['log4j']['level']              = 'INFO'
default['solrcloud']['log4j']['console']            = false
default['solrcloud']['log4j']['max_file_size']      = '100MB'
default['solrcloud']['log4j']['max_backup_index']   = '10'
default['solrcloud']['log4j']['conversion_pattern'] = '%d{ISO8601} [%t] %-5p %c{3} %x - %m%n'

# solr.xml config
default['solrcloud']['solr_config']['admin_handler']        = 'org.apache.solr.handler.admin.CoreAdminHandler'
default['solrcloud']['solr_config']['admin_path']           = node['solrcloud']['jetty_config']['context']['path'] + '/admin'
default['solrcloud']['solr_config']['core_load_threads']    = 3
default['solrcloud']['solr_config']['management_path']      = nil
default['solrcloud']['solr_config']['share_schema']         = 'false'
default['solrcloud']['solr_config']['transient_cache_size'] = 1_000_000
default['solrcloud']['solr_config']['solrcloud']['host_context']       = node['solrcloud']['context_name']
default['solrcloud']['solr_config']['solrcloud']['distrib_update_conn_timeout']    = 1_000_000
default['solrcloud']['solr_config']['solrcloud']['distrib_update_so_timeout']      = 1_000_000
default['solrcloud']['solr_config']['solrcloud']['leader_vote_wait']   = 1_000_000
default['solrcloud']['solr_config']['solrcloud']['zk_client_timeout']  = 15_000
default['solrcloud']['solr_config']['solrcloud']['zk_host']     = []  # syntax: ["zkHost:zkPort"]
default['solrcloud']['solr_config']['solrcloud']['zk_chroot']   = nil # syntax: '/solr'
default['solrcloud']['solr_config']['solrcloud']['generic_core_node_names']        = 'true'

default['solrcloud']['solr_config']['shard_handler_factory']['socket_timeout']       = 0
default['solrcloud']['solr_config']['shard_handler_factory']['conn_timeout']         = 0

default['solrcloud']['solr_config']['logging']['enabled']        = 'true'
default['solrcloud']['solr_config']['logging']['logging_class']  = nil

default['solrcloud']['solr_config']['logging']['watcher']['logging_size']  = 1000
default['solrcloud']['solr_config']['logging']['watcher']['threshold']     = 'INFO'

# Solr Directories
default['solrcloud']['solr_home']   = ::File.join(node['solrcloud']['install_dir'], 'solr')
default['solrcloud']['cores_home']  = ::File.join(node['solrcloud']['solr_home'], 'cores/')
default['solrcloud']['shared_lib']  = ::File.join(node['solrcloud']['install_dir'], 'lib')

# Solr default configSets directory
default['solrcloud']['config_sets'] = ::File.join(node['solrcloud']['solr_home'], 'configsets')

default['solrcloud']['zk_run_data_dir']  = ::File.join(node['solrcloud']['install_dir'], 'zookeeperdata')

# Set zkHost for zookeeper configSet management
default['solrcloud']['solr_config']['solrcloud']['zk_host'] = ["#{node['ipaddress']}:#{node['solrcloud']['zk_run_port']}"] if node['solrcloud']['zk_run']

# Solr Zookeeper configSets directory (collection.configName)
default['solrcloud']['zkconfigsets_home'] = '/usr/local/solr_zkconfigsets'

default['solrcloud']['solr_config']['core_root_directory']      = node['solrcloud']['cores_home']
default['solrcloud']['solr_config']['shared_lib']               = node['solrcloud']['shared_lib']
default['solrcloud']['solr_config']['solrcloud']['host_port']   = node['solrcloud']['port']

default['solrcloud']['source_dir']      = '/usr/local/solr-' + node['solrcloud']['version']
default['solrcloud']['tarball']['url']  = "https://archive.apache.org/dist/lucene/solr/#{node['solrcloud']['version']}/solr-#{node['solrcloud']['version']}.tgz"
default['solrcloud']['tarball']['md5']  = '316f11ed8e81cf07ebfa6ad9443add09'

default['solrcloud']['key_store']['key_store_file_path']  = ::File.join(node['solrcloud']['install_dir'], 'etc', node['solrcloud']['key_store']['key_store_file'])

default['solrcloud']['jmx']['password_file']  = ::File.join(node['solrcloud']['install_dir'], 'resources', 'jmxremote.password')
default['solrcloud']['jmx']['access_file']    = ::File.join(node['solrcloud']['install_dir'], 'resources', 'jmxremote.access')
