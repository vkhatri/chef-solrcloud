default[:solrcloud] = {
  :user         => 'solr',
  :group        => 'solr',
  :user_home    => nil,
  :setup_user   => false,
  :version      => '4.9.0',
  :install_dir  => '/usr/local/solr',
  :data_dir     => '/opt/solr',
  :notify_restart   => false, # notify service restart on config change 
  :service_name     => 'solr', 
  :solr_role        => 'master', # keeping it around for developemnt releases
  :dir_mode     => '0755', # default directory permissions used by solrcloud cookbook
  :pid_dir      => '/var/run/solr', # solr service user pid dir
  :log_dir      => '/var/log/solr',
  :cookbook     => "solrcloud", # template source cookbook
  :templates_cookbook => "solrcloud", # template source cookbook

  :limits => {
    :memlock    => 'unlimited',
    :nofile     => 48000,
    :nproc      => 'unlimited'
  },

  :log4j        => {
    :max_file_size    => '10MB',
    :max_backup_index => '10'
  },

  :jetty        => {
    :port       => '8080'
  },

  :admin_handler      => 'org.apache.solr.handler.admin.CoreAdminHandler',
  :admin_path         => '/solr/admin',
  :share_schema       => false,
  :core_load_threads  => 3,

  :cores        => {}
}

# Solr Home
default[:solrcloud][:solr_home]   = File.join(node.solrcloud.install_dir,'solr')
default[:solrcloud][:cores_home]  = File.join(node.solrcloud.solr_home,'cores')
default[:solrcloud][:shared_lib]  = File.join(node.solrcloud.install_dir,'coreslib')
default[:solrcloud][:config_sets] = File.join(node.solrcloud.solr_home,'configsets')
default[:solrcloud][:contrib]     = File.join(node.solrcloud.install_dir,'contrib')
default[:solrcloud][:dist]        = File.join(node.solrcloud.install_dir,'dist')

# Enable Local Zookeeper
default[:solrcloud][:zookeeper][:self]  = false
# Default Port for Zookeeper
default[:solrcloud][:zookeeper][:port]  = 2181

if node[:solrcloud][:zookeeper][:self]
  default[:solrcloud][:zookeeper][:servers]  = ["#{node.ip_address}:#{node.solrcloud.zookeeper.port}"] 
else
# Syntax: [server:port, server:port]
  default[:solrcloud][:zookeeper][:servers]  = []
end

default[:solrcloud][:source_dir]      = "/usr/local/solr-#{node.solrcloud.version}"
default[:solrcloud][:tarball][:url]   = "https://archive.apache.org/dist/lucene/solr/#{node['solrcloud']['version']}/solr-#{node['solrcloud']['version']}.tgz"
default[:solrcloud][:tarball][:md5]   = '316f11ed8e81cf07ebfa6ad9443add09'

