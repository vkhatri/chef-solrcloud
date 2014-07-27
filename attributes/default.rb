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
  :collections  => {}

=begin
e.g.
  :collections    => {
    :collection1  => {
      :action     => 'create',
      :cores      => {
        :core1    => {
          :action => 'create',
        }
      }
    }
    :collection2  => {
      :action     => 'create',
      :cores      => {
        :core1    => {
          :action => 'create',
        }
      }
    }
  }
=end

}

# Solr Home
default[:solrcloud][:solr_home]  = File.join(node.solrcloud.install_dir,'solr')

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

