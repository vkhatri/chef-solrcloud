# solr v5.2.1+ specific attributes
#

default['solrcloud']['solr_config']['gc_log_opts'] = [] # %w(-verbose:gc -XX:+PrintHeapAtGC -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps -XX:+PrintTenuringDistribution -XX:+PrintGCApplicationStoppedTime)

default['solrcloud']['solr_config']['gc_tune'] = %w(-XX:NewRatio=3
                                                    -XX:SurvivorRatio=4
                                                    -XX:TargetSurvivorRatio=90
                                                    -XX:MaxTenuringThreshold=8
                                                    -XX:+UseConcMarkSweepGC
                                                    -XX:+UseParNewGC
                                                    -XX:ConcGCThreads=4
                                                    -XX:ParallelGCThreads=4
                                                    -XX:+CMSScavengeBeforeRemark
                                                    -XX:PretenureSizeThreshold=64m
                                                    -XX:+UseCMSInitiatingOccupancyOnly
                                                    -XX:CMSInitiatingOccupancyFraction=50
                                                    -XX:CMSMaxAbortablePrecleanTime=6000
                                                    -XX:+CMSParallelRemarkEnabled
                                                    -XX:+ParallelRefProcEnabled)

# whether to use node fqdn or ip addressfor solr host
default['solrcloud']['solr_config']['solr_host_type'] = 'fqdn' # options: fqdn, ip
# fallback to node ip address if node fqdn is not set
default['solrcloud']['solr_config']['solr_host'] = nil # node[node['solrcloud']['solr_config']['solr_host_type']] || node['ip']

default['solrcloud']['solr_config']['solr_timezone'] = 'UTC'
