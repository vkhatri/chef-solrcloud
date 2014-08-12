name             'solrcloud'
maintainer       'Virender Khatri'
maintainer_email 'vir.khatri@gmail.com'
license          'Apache 2.0'
description      'Installs/Configures Apache Solr'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.2.8'

depends "java"
depends "ulimit"

%w{ubuntu centos redhat fedora amazon}.each do |os|
  supports os
end
