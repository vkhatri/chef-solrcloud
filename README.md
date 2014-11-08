solrcloud Cookbook
==================

[![Build Status](https://travis-ci.org/vkhatri/chef-solrcloud.svg?branch=master)](https://travis-ci.org/vkhatri/chef-solrcloud)

This is a [Chef] cookbook for [Apache Solr].

It was primarily developed for Testing SolrCloud against Solr Master/Slave setup and its features.

Currently it supports only in built Jetty based SolrCloud deployment, more
features and attributes will be added over time, **feel free to contribute**
what you find missing!

SolrCloud is the default deployment and Solr Master/Slave setup is not supported
by this cookbook.


## Repository

http://vkhatri.github.io/chef-solrcloud


## Supported Apache Solr Version

This cookbook was tested for Apache Solr v4.9.0 and v4.10.x.


## Supported Apache Solr Runtime

Currently this cookbook supports only Apache Solr in built [Jetty] based deployment.


## Supported Apache Solr Package Deployment

Currently this cookbook only supports Apache Solr Tarball based deployment.


## Supported Apache Solr Cluster Deployment

Currently this cookbook only support SolrCloud Cluster deployment. It does not
support Apache Solr Master/Slave Cluster deployment.


## Supported JDK Versions

Check [Apache Solr] Documentation for JDK Version requirement for current Solr version, Oracle JDK 7 is recommended.


## Recipes

- `solrcloud::tarball`     	- install solr package, directories and service

- `solrcloud::config`  		- manages solr base configuration files

- `solrcloud::jetty`   		- manages jetty base configuration files and directories

- `solrcloud::zkcli`		- setup zookeeper package for zookeeper client binary (zkCli.sh)

		zkcli recipe does not manage zookeeper server and its only purpose
		is to have zookeeper client on all solr nodes

- `solrcloud::user`			- create solr service user

		solr user is better to be managed by a User management cookbook
		instead of solrcloud for Production environment.

- `solrcloud::zkconfigsets`	- create/delete solrcloud configSet in zookeeper via LWRP

- `solrcloud::collections` 	- create/delete solrcloud collection on solrcloud node via LWRP


> `solrcloud::tarball` is the main recipe which includes all other recipe. For `run_list` use `solrcloud::tarball`.


## SolrCloud configSet (Zookeeper Configs) LWRP


**LWRP - solrcloud_zkconfigset**

SolrCloud Zookeeper configSet is managed via LWRP - `solrcloud_zkconfigset`.

SolrCloud Zookeeper configSets management is enabled by default for all nodes.
It means all nodes will get the configSets and will try to manage it against
one of the configured zookeeper server via attribute `node[:solrcloud][:solr_config][:solrcloud][:zk_host]`.

    All the nodes communicate to a zookeeper cluster, hence attribute
    `node[:solrcloud][:manage_zkconfigsets]` & `node[:solrcloud][:manage_zkconfigsets_source]`
    does not require to be enabled on all the nodes.

Check `Cookbook Advanced Attributes` section for attribute details.


**zookeeper configSet config changes**

LWRP handles config changes by itself. When any change is made to configSet content, configSet will re-upload configSet to zookeeper.


**LWRP example**

*Create a configSet using LWRP:*

    solrcloud_zkconfigset configset_name
      option option_name
    end


*Always re create/upload configSet even exists or no update to config files:*

    solrcloud_zkconfigset configset_name
      force_upload true
      option option_name
    end

OR

Set attribute `node[:solrcloud][:force_zkconfigsets_upload]` to true, which affects all the configSets as
resource attribute :force_upload defualt value is set to `node[:solrcloud][:force_zkconfigsets_upload]`.


*Delete a configSet using LWRP:*

    solrcloud_zkconfigset configset_name do
      action :delete
    end


*configSet via node attribute:*

    "default_attributes": {
      "solrcloud": {
        "zkconfigsets": {
          "abc": {
            "action": "delete"
          },
          "xyz": {
	        "option name": "option value"
          }
        }
      }
    }

> configSets can either be configured in recipe using LWRP or using node attribute `node[:solrcloud][:zkconfigsets]`.

> configSets defined using attribute `node[:solrcloud][:zkconfigsets]` does not require LWRP.


**LWRP Options**

SolrCloud Zookeeper cmd Reference: https://cwiki.apache.org/confluence/display/solr/Command+Line+Utilities

Parameters:

- *configset_name (required)*			- solrcloud zookeeper configSet name
- *action (optional)*					- default :create, options: :create, :delete
- *user (optional)*						- configSet directory user permission, default value `node[:solrcloud][:user]`
- *group (optional)*					- configSet directory group permission, default value `node[:solrcloud][:group]`
- *solr_zkcli (optional)*				- solr in built zkcli.sh for configSet upconfig, default value `node[:solrcloud][:zookeeper][:solr_zkcli]`
- *zkcli (optional)*					- zookeeper client zkCli.sh, default value `node[:solrcloud][:zookeeper][:zkcli]`
- *zkhost (optional)*					- zookeeper server, default value `node[:solrcloud][:solr_config][:solrcloud][:zk_host].first`
- *zkconfigsets_home (optional)*		- configSet directory to sore on solrcloud node, default value `node[:solrcloud][:zkconfigsets_home]`
- *zkconfigsets_cookbook (optional)*	- configSet cookbook name, default value `node[:solrcloud][:zkconfigsets_cookbook]`
- *manage_zkconfigsets (optional)* - manage configSet, default value `node[:solrcloud][:manage_zkconfigsets]`
- *force_upload (optional)* - if set always upload configSet to zookeeper, default value `node[:solrcloud][:force_zkconfigsets_upload]`

**LWRP configSet source cookbook/location management**

All configSet content must be stored under `node[:solrcloud][:zkconfigsets_cookbook]`/files/default/config set name/conf/` if
not managed separately.

configSets source cookbook is default set to `solrcloud` and can be changed via attribute `node[:solrcloud][:zkconfigsets_cookbook]`.

If configSets are managed outside of the cookbook, configSet will only get uploaded in case it is missing in the zookeeper.
Any update to separately managed configSets are not propogated to zookeeper by default. However, one can use attribute
`node[:solrcloud][:force_zkconfigsets_upload]` to always upload the configSet regardless of the state.

> Setting attribute node[:solrcloud][:force_zkconfigsets_upload] or resource attribute :force_upload would always trigger configSet upload to zookeeper. It is better not to enable rsource attribute :force_upload, but instead better to use attribute node[:solrcloud][:force_zkconfigsets_upload] on limited set of nodes.

> This may vary environment to environment.


## SolrCloud Collection LWRP

**LWRP - solrcloud_collection**

SolrCloud collection is managed via LWRP - `solrcloud_collection`.

> Create/Delete Collection API does not require to run on all solrcloud cluster nodes, hence attribute

> `node[:solrcloud][:manage_collections]` does not require to be enabled on all the nodes.

Check `Cookbook Advanced Attributes` section for attribute details.


**collection Update/Change**

collection LWRP only perform collection action=CREATE|DELETE|RELOAD and does not manage any UPDATE/change in the collection.

To make a change to a collection, first make the change in the LWRP or node attribute `node[:solrcloud][:collections][:collection_nam][:attribute_name]`
for respective attribute.

Once changes are made in Chef cookbook, perform collection UPDATE or respective action call to one of the solrcloud node.

UPDATE call could be tricky and is not managed by Chef to avoid any unexpected behavior.

Re-issuing same command could hinder solrcloud cluster setup and must be re-issued carefully.


**LWRP example**

*Create a collection using LWRP:*

    solrcloud_collection collection_name
      option option_name
    end


*Delete a collection using LWRP:*

    solrcloud_collection collection_name do
      action :delete
    end

*Reload a collection using LWRP:*

    solrcloud_collection collection_name do
      action :reload
    end

*collection via node attribute:*

    "default_attributes": {
      "solrcloud": {
        "collections": {
          "abc": {
            "action": "delete"
          },
          "def": {
            "action": "reload"
          },
          "xyz": {
            "num_shards": "1",
            "name": "xyz",
            "replication_factor": "1",
            "collection_config_name": "xyz",
            "option name": "value"
          }
	    }
      }
    }


> collections can either be configured in recipe using LWRP or using node attribute `node[:solrcloud][:collections]`.

> collections defined using attribute `node[:solrcloud][:collections]` does not require LWRP.


**LWRP Options**

Collection API Reference: https://cwiki.apache.org/confluence/display/solr/Collections+API


Parameters:

- *collection_config_name* (required)			- solrcloud zookeeper configSet name
- *action* (optional)							- default :create, options: :create, :delete, :reload
- *context_path* (optional)						- solr context path, default value `node['solrcloud']['jetty_config']['context']['path']`
- *num_shards* (optional)						- collection API parameter numShards, default value 1
- *shards* (optional)							- collection API parameter shards, default value nil
- *router_field* (optional)						- collection API parameter router.field, default value nil
- *async* (optional)							- collection API parameter async, default value nil
- *router_name* (optional)						- collection API parameter router.name, default value nil
- *router_field* (optional)						- collection API parameter router.field, default value nil
- *host* (optional)								- collection API host, solrcloud node (self), default value `node[:ipaddress]`
- *use_ssl* (optional)						- collection API, use https, default value false
- *port* (optional)								- collection API host port, solrcloud port, default value `node[:solrcloud][:port]`
- *ssl_port_* (optional)						- collection API host ssl port, default value `node[:solrcloud][:ssl_port]`
- *create_node_set* (optional)					- collection API parameter createNodeSet, default value nil
- *replication_factor* (optional)				- collection API parameter replicationFactor, default value 1
- *max_shards_per_node* (optional)				- collection API parameter maxShardsPerNode, default value nil
- *auto_add_replicas* (optional)				- collection API parameter autoAddReplicas, default value false


## Cookbook Advanced Attributes

 * `default[:solrcloud][:manage_zkconfigsets]` (default: `true`): manages solrcloud configSets in zookeeper

    This attribute should be enabled for limited nodes in solrcloud cluster if possible.

 * `default[:solrcloud][:manage_zkconfigsets_source]` (default: `true`): manages solrcloud collections configSets source content directory

        This attribute should be enabled for limited nodes in solrcloud cluster if possible.

 * `default[:solrcloud][:notify_zkconfigsets_upload]` (default: `true`): notify/triggers configSet upload to zookeeper upon create/update

        This attribute should be enabled for limited nodes in solrcloud cluster if possible.

 * `default[:solrcloud][:manage_collections]` (default: `true`): if set true, manages solrcloud cluster collections

        This attribute should be enabled for limited nodes in solrcloud cluster if possible.

 * `default[:solrcloud][:notify_restart]` (default: `false`): notify solr service restart on a solrcloud resource change like config file/template etc.

 * `default[:solrcloud][:notify_restart_upgrade]` (default: `false`): notify solr service restart on version upgrade

 * `default[:solrcloud][:restore_cores]` (default: `true`): restore older version solr cores configuration to newer version

        Note: Disable this option if reverting back to an old version. Before restoring the cores, new version cores directory content gets purged.

        If there are changes in cores configuration between older and newer versions, only current(older) version cores configuration will presists.

 * `default[:solrcloud][:zk_run]` (default: `false`): if true solr will start up with embedded zookeeper

        Note: Setting option `node[:solrcloud][:zk_run]` will remove solrcloud config zk_host from solr.xml, mainly meant for testing purpose

 * `default[:solrcloud][:enable_jmx]` (default: `true`): enable jmx

 * `default[:solrcloud][:port]` (default: `8983`): solr service port, must be (>1024 for non root user)

 * `default[:solrcloud][:ssl_port]` (default: `8984`): solr ssl service port (>1024 for non root user)

 * `default[:solrcloud][:enable_ssl]` (default: `true`): enable solr ssl connector

 * `default[:solrcloud][:enable_request_log]` (default: `true`): enable request log

 * `default[:solrcloud][:solr_config][:solrcloud][:zk_host]` (default: `[]`): zookeeper servers, e.g. `["server:port", "server:port"]`

        With attribute `default[:solrcloud][:zk_run]`, this attribute will get local zookeeper server.

 * `default[:solrcloud][:java_options]` (default: `[]`): java options

 * `default[:solrcloud][:auto_java_memory]` (default: `true`): enable auto java memory allocation, sets java attribute `-Xmx` for `node[:solrcloud][:java_options]`

		This option calculates maximum allowed memory (multiple of 1024) for java process with minimum system memory 		reservation defined by attribute `node[:solrcloud][:auto_system_memory]`

 * `default[:solrcloud][:auto_system_memory]` (default: `768`): memory to preserve for OS, required when attribute `default[:solrcloud][:auto_java_memory]` is set

 * `default[:solrcloud][:install_java]` (default: `true`): setup java, disable to manage java outside of this cookbook

 * `default[:solrcloud][:context_name]` (default: `solr`): default solr jetty context path value

 * `default[:solrcloud][:force_zkconfigsets_upload]` (default: `false`): if set, zkconfigset lwrp will always execute configSet upload to zookeeper even configSet exists or there is no update. This option is useful when configSet source directory is managed separately.

        This attribute should be enabled for limited nodes in solrcloud cluster if possible.

## Cookbook Core Attributes

 * `default[:solrcloud][:user]` (default: `solr`): solr service user

 * `default[:solrcloud][:group]` (default: `solr`): solr service group

 * `default[:solrcloud][:user_home]` (default: `nil`): solr service user home

 * `default[:solrcloud][:setup_user]` (default: `true`): manage solr user for solr service using `solrcloud::user` cookbook

 * `default[:solrcloud][:version]` (default: `4.10.2`): solr package version

 * `default[:solrcloud][:zk_run_data_dir]` (default: `node[:solrcloud][:install_dir]/zookeeperdata`): embedded zookeeper data directory

 * `default[:solrcloud][:zk_run_port]` (default: `2181`): embedded zookeeper port

 * `default[:solrcloud][:install_dir]` (default: `/usr/local/solr`): jetty home directory - jetty.home

 * `default[:solrcloud][:data_dir]` (default: `/opt/solr`): solr collection data directory - solr.data.dir

        solrconfig.xml for each configSet needs to set dataDir for this location usage, like:
          <dataDir>${solr.data.dir:}/collection name</dataDir>

 * `default[:solrcloud][:solr_home]` (default: `node[:solrcloud][:install_dir]/solr`): solr home

 * `default[:solrcloud][:cores_home]` (default: `node[:solrcloud][:solr_home]/cores`): solr collection/core home

 * `default[:solrcloud][:shared_lib]` (default: `node[:solrcloud][:install_dir]`/lib): solr default lib directory

 * `default[:solrcloud][:config_sets]` (default: `node[:solrcloud][:solr_home]/configsets`): solr cores configSets directory

 * `default[:solrcloud][:service_name]` (default: `solr`): solr service name

 * `default[:solrcloud][:service_start_wait]` (default: `15`): solr server after start up wait time

 * `default[:solrcloud][:dir_mode]` (default: `0755`): solr resource default directory

 * `default[:solrcloud][:pid_dir]` (default: `/var/run/solr`): solr pid directory

 * `default[:solrcloud][:log_dir]` (default: `/var/log/solr`): solr log directory

 * `default[:solrcloud][:template_cookbook]` (default: `solrcloud`): solr template resources cookbook

 * `default[:solrcloud][:zkconfigsets_cookbook]` (default: `solrcloud`): zookeeper configSet cookbook

 * `default[:solrcloud][:zkconfigsets_home]` (default: `/usr/local/solr_zkconfigsets`): configs location for zookeeper configSet upconfig

 * `default[:solrcloud][:zookeeper][:version]` (default: `3.4.6`): zookeeper package setup for zkCli.sh


## Cookbook Ulimit Attributes

 * `default[:solrcloud][:limits][:memlock]` (default: `unlimited`): solr service user memory limit

 * `default[:solrcloud][:limits][:nofile]` (default: `48000`): solr service user file limit

 * `default[:solrcloud][:limits][:nproc]` (default: `unlimited`): solr service user process limit


## Cookbook log4j.properties Config Attributes

 * `default[:solrcloud][:log4j][:level]` (default: `10MB`):  solr log threshold

 * `default[:solrcloud][:log4j][:console]` (default: `false`): enable/disable CONSOLE log

 * `default[:solrcloud][:log4j][:max_file_size]` (default: `10MB`):  maximum log file size

 * `default[:solrcloud][:log4j][:max_backup_index]` (default: `10`): log files retention

 * `default[:solrcloud][:log4j][:conversion_pattern]` (default: `'%d{ISO8601} [%t] %-5p %c{3} %x - %m%n'`): log conversion pattern

## Cookbook Request Log Config Attributes

 * `default[:solrcloud][:request_log][:retain_days]` (default: `10`): request log files retention

 * `default[:solrcloud][:request_log][:log_cookies]` (default: `false`):  enable log cookies

 * `default[:solrcloud][:request_log][:time_zone]` (default: `UTC`): request log time zone

## Cookbook Jetty Core Server Attributes

 * `default[:solrcloud][:jetty_config][:server][:min_threads]` (default: `10`): minimum jetty threads

 * `default[:solrcloud][:jetty_config][:server][:max_threads]` (default: `10000`): maximum jetty threads

 * `default[:solrcloud][:jetty_config][:server][:detailed_dump]` (default: `false`): enable jetty detailed dump

## Cookbook Jetty Default Connector Attributes (org.eclipse.jetty.server.bio.SocketConnector)

 * `default[:solrcloud][:jetty_config][:connector][:stats_on]` (default: `true`): enable statistics

 * `default[:solrcloud][:jetty_config][:connector][:max_idle_time]` (default: `50000`): max idle time for connector (http)

 * `default[:solrcloud][:jetty_config][:connector][:low_resource_max_idle_time]` (default: `1500`):

## Cookbook Jetty SSL Connector Attributes

 * `default[:solrcloud][:jetty_config][:ssl_connector][:need_client_auth]` (default: `false`): enable client ssl authentication, this feature is not tested yet

 * `default[:solrcloud][:jetty_config][:ssl_connector][:max_idle_time]` (default: `30000`): jetty ssl maximum idle time


## Cookbook Jetty SSL Key Store Attributes

 * `default[:solrcloud][:key_store][:manage]` (default: `true`): generate key store for node key store attribute (enabled for testing purpose)

 * `default[:solrcloud][:key_store][:key_store_file]` (default: `solr.keystore`): key store file name, file location - node.solrcloud.install_dir/resources/etc/

 * `default[:solrcloud][:key_store][:key_store_password]` (default: ``): key store password

 * `default[:solrcloud][:key_store][:cookbook]` (default: `solrcloud`): jetty ssl key store source cookbook, required is cookbook filekey store file management is disabled. Typical for Production environment.

 * `default[:solrcloud][:key_store][:key_algo]` (default: `RSA`): key store Algorithm

 * `default[:solrcloud][:key_store][:cn]` (default: `localhost`): key store CN

 * `default[:solrcloud][:key_store][:ou]` (default: `ApacheSolrCloudTest`): key store OU

 * `default[:solrcloud][:key_store][:o]` (default: `lucene.apache.org`): key store O

 * `default[:solrcloud][:key_store][:c]` (default: `US`): key store C

 * `default[:solrcloud][:key_store][:ext]` (default: `san=ip:127.0.0.1`): key store ext params

 * `default[:solrcloud][:key_store][:validity]` (default: `999999`): key store validity

## Cookbook Jetty JMX Attributes

 * `default[:solrcloud][:jmx][:port]` (default: `1099`): jmx port

 * <del>`default[:solrcloud][:jmx][:ssl]` (default: `false`): this feature is not available yet and disabled</del>

 * <del>`default[:solrcloud][:jmx][:authenticate]` (default: `false`): enable jmx authentication and authorization, this feature is not tested yet</del>

 * `default[:solrcloud][:jmx][:users]` (default: `users - solrmonitor solrconfig`): jmx defaults users and roles, this feature is not tested yet

## Cookbook Jetty Context Attributes
 * `default[:solrcloud][:jetty_config][:context][:path]` (default: `/solr`): solr default context path

 * `default[:solrcloud][:jetty_config][:context][:temp_directory]` (default: `/solr-webapp`): solr webapp directory

 * `default[:solrcloud][:jetty_config][:context][:war]` (default: `/webapps/solr.war`): jetty webapp solr war file location

## Cookbook solr.xml Config Attributes

solr.xml Reference: https://cwiki.apache.org/confluence/display/solr/Format+of+solr.xml

 * `default[:solrcloud][:solr_config][:admin_handler]` (default: `org.apache.solr.handler.admin.CoreAdminHandler`): solr.xml solr param adminHandler

 * `default[:solrcloud][:solr_config][:admin_path]` (default: `/solr/admin`): solr.xml param adminPath

 * `default[:solrcloud][:solr_config][:core_load_threads]` (default: `3`): solr.xml solr param coreLoadThreads

 * `default[:solrcloud][:solr_config][:core_root_directory]` (default: `node[:solrcloud][:cores_home]`): solr.xml solr param coreRootDirectory

 * `default[:solrcloud][:solr_config][:shared_lib]` (default: `node[:solrcloud][:shared_lib]`): solr.xml solr param sharedLib

 * `default[:solrcloud][:solr_config][:management_path]` (default: `nil`): solr.xml solr param managementPath

 * `default[:solrcloud][:solr_config][:share_schema]` (default: `false`): solr.xml solr param shareSchema

 * `default[:solrcloud][:solr_config][:transient_cache_size]` (default: `1000000`): solr.xml solr param transientCacheSize

 * `default[:solrcloud][:solr_config][:solrcloud][:host_context]` (default: `solr`): solr.xml param solrcloud hostContext

 * `default[:solrcloud][:solr_config][:solrcloud][:distrib_update_conn_timeout]` (default: `1000000`): solr.xml param solrcloud distribUpdateConnTimeout

 * `default[:solrcloud][:solr_config][:solrcloud][:distrib_update_so_timeout]` (default: `1000000`): solr.xml param solrcloud distribUpdateSoTimeout

 * `default[:solrcloud][:solr_config][:solrcloud][:leader_vote_wait]` (default: `1000000`): solr.xml param solrcloud leaderVoteWait

 * `default[:solrcloud][:solr_config][:solrcloud][:zk_client_timeout]` (default: `15000`): solr.xml param solrcloud zkClientTimeout

 * `default[:solrcloud][:solr_config][:solrcloud][:zk_host]` (default: `[]`): zookeeper servers, e.g. `["server:port", "server:port"]`

 * `default[:solrcloud][:solr_config][:solrcloud][:generic_core_node_names]` (default: `true`): solr.xml param solrcloud genericCoreNodeNames

 * `default[:solrcloud][:solr_config][:shard_handler_factory][:socket_timeout]` (default: `0`): solr.xml param shardHandlerFactory socketTimeout

 * `default[:solrcloud][:solr_config][:shard_handler_factory][:conn_timeout]` (default: `0`): solr.xml param shardHandlerFactory connTimeout

 * </del>`default[:solrcloud][:solr_config][:logging][:enabled]` (default: `false`): solr.xml param logging enabled, not required</del>

 * </del>`default[:solrcloud][:solr_config][:logging][:logging_class]` (default: `nil`): solr.xml param logging class, not required </del>

 * </del>`default[:solrcloud][:solr_config][:logging][:watcher][:logging_size]` (default: `1000`): solr.xml param logging size, not required</del>

 * </del>`default[:solrcloud][:solr_config][:logging][:watcher][:threshold]` (default: `INFO`): solr.xml param logging threshold, no required</del>


## Cookbook SolrCloud on HDFS Config Attributes

 * `default[:solrcloud][:hdfs][:enable]` (default: `false`): to run solrcloud on hdfs, set it to `true`

 * `default[:solrcloud][:hdfs][:directory_factory]` (default: `HdfsDirectoryFactory`): solr hdfs directory factory

 * `default[:solrcloud][:hdfs][:lock_type]` (default: `hdfs`): sold hdfs lock type

 * `default[:solrcloud][:hdfs][:hdfs_home]` (default: `nil`): syntax: 'hdfs://host:port/path'

> Note: SolrCloud on HDFS Deployment using this cookbook is not yet tested, check online [solr on hdfs] for more info


## Cookbook Dependencies

* `ulimit` cookbook
* `java` cookbook


## SolrCloud Deployment Requirement

To deploy solrcloud using this cookbook, below items are required:

- a zookeeper server or cluster
- configSet(s) to upload to zookeeper for collection/core
- collection(s) name to deploy in solrcloud


## SolrCloud configSet Cookbook / Environments / Versioning

*Directory Structure*

SorlCloud configSet stored in zookeeper are configured as file resources.

Each configSet is stored under `node[:solrcloud][:zkconfigsets_cookbook]/files/default/configSet name`.

configSet folder follows the standard of having a `conf` folder with all the configuration files.

So, the directory structure will look like - `node[:solrcloud][:zkconfigsets_cookbook]/files/default/configSet name/conf`.

*Managing same configSet for Multiple Environments*

Managing configSet configuration across environments can be achieved in different ways, like

- maintain different `node[:solrcloud][:zkconfigsets_cookbook]` per environment
OR
- maintain a single cookbook with versioning


Simply, update `node[:solrcloud][:zkconfigsets_cookbook]` attribute with your configSet cookbook and update metadata.rb
file with line:

'depends `node[:solrcloud][:zkconfigsets_cookbook]`'.


## Single Node SolrCloud Test Cluster Deployment


Adjust the attributes according to your requirement. Below mentioned attributes
will work just fine for a single node solrcloud cluster.


	"default_attributes": {
      "solrcloud": {
		"zk_run": true,
        "port": "8080",
        "setup_user": true,
        "manager": true,
        "zkconfigsets": {
          "samplecollection": {}
        },
        "collections": {
          "samplecollection": {
            "collection_config_name": "samplecollection"
          }
        }
      }
  	}


## Multi Node Manager Attributes

Below attributes are crucial for Multi Node Cluster. It is not advised to enable below solrcloud attributes on all
the nodes in the cluster. Like, each new node will trigger a zookeeper configset re-upload. Creating new collection
is better off maanged by one node to prevent a false collection state in the cluster.


	"default_attributes": {
      "solrcloud": {
      	"manage_collections": true,
      	"manage_zkconfigsets": true,


## Multi Node SolrCloud Test Cluster Deployment with zookeeper Cluster


Adjust the attributes according to your requirement. Below mentioned attributes
will work just fine for a single node solrcloud cluster.


	"default_attributes": {
      "solrcloud": {
        "solr_config": {
          "solrcloud": {
            "zk_host": [
              "zookeeper_ip:zookeeper_port"
            ]
          }
		},
        "port": "8080",
        "setup_user": true,
      	"manage_collections": true,
      	"manage_zkconfigsets": true,
        "zkconfigsets": {
          "samplecollection": {}
        },
        "collections": {
          "samplecollection": {
            "collection_config_name": "samplecollection"
          }
        }
      }
  	}

> Note: You might want to enable attribute `"manager": true` on limited cluster nodes. In a large
> cluster, enabling this value on limited nodes would create less overhead for zookeeper.


## Multi Node SolrCloud Test Cluster Deployment with embedded zookeeper


Adjust the attributes according to your requirement. Below mentioned attributes
will work just fine for a single node solrcloud cluster.


On `any one` of the cluster node, enable attribute `node[:solrcloud][:zk_run]` and use its ip address as zookeeper server.

	"default_attributes": {
      "solrcloud": {
        "solr_config": {
          "solrcloud": {
            "zk_host": [
              "instance_with_zk_run_ip:zookeeper_port_default_2181"
            ]
          }
		},
        "port": "8080",
        "setup_user": true,
        "zkconfigsets": {
          "samplecollection": {}
        },
        "collections": {
          "samplecollection": {
            "collection_config_name": "samplecollection"
          }
        }
      }
  	}


## Multiple SolrCloud Cluster Deployment

To deploy multiple clusters, simply create multiple roles with different zookeeper server or update
node attribute with respective cluster zookeeper server(s).

Zookeeper server attribute - `node[:solrcloud][:solr_config][:solrcloud][:zk_host]`


## SolrCloud on HDFS Cluster Deployment

SolrCloud on HDFS has not been tested yet, but configuration from Apache Solr documentation has been
added to the cookbook.


## Tune Java Parameters for better Performance

Some of the common java options tuning by [Shawn Heisey].

Node attributes:

    "default_attributes": {
      "solrcloud": {
        "java_options": [
          "-Xms1024m",
          "-XX:+UseConcMarkSweepGC",
          "-XX:CMSInitiatingOccupancyFraction=75",
          "-XX:NewRatio=3",
          "-XX:MaxTenuringThreshold=8",
          "-XX:+CMSParallelRemarkEnabled",
          "-XX:+ParallelRefProcEnabled",
          "-XX:+AggressiveOpts"
        ]
      }
    }


## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests (`rake`), ensuring they all pass
6. Write new resource/attribute description to `README.md`
7. Write description about changes to PR
8. Submit a Pull Request using Github


## Copyright & License

Authors:: Virender Khatri and [Contributors]

<pre>
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
</pre>


[Jetty]: http://wiki.apache.org/solr/SolrJetty
[Apache Solr]: http://lucene.apache.org/solr/
[solr on hdfs]: https://cwiki.apache.org/confluence/display/solr/Running+Solr+on+HDFS
[Chef]: https://www.getchef.com/chef/
[Contributors]: https://github.com/vkhatri/chef-solrcloud/graphs/contributors
[Shawn Heisey]: https://wiki.apache.org/solr/ShawnHeisey
