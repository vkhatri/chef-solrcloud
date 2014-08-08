solrcloud Cookbook
==================

This is an OpsCode Chef cookbook for [Apache Solr].

It was primarily developed for Testing SolrCloud against Solr Master/Slave setup and its features. 

Currently it supports only in built Jetty based SolrCloud deployment, more
features and attributes will be added over time, **feel free to contribute** 
what you find missing!

SolrCloud is the default deployment and Solr Master/Slave setup is not supported
by this cookbook.


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
 
		zkcli recipe does not manage zookeeper server and only purpose 
		is to have zookeeper client on all solr nodes

* `solrcloud::user`			- create solr service user
 
		solr user is better to be managed by a User management cookbook
		instead of solrcloud for Production environment.

* `solrcloud::zkconfigsets`	- create/delete solrcloud configSet in zookeeper via LWRP 

* `solrcloud::collections` 	- create/delete solrcloud collection on solrcloud node via LWRP



## SolrCloud configSet (Zookeeper Configs) LWRP


**LWRP - solrcloud_zkconfigset**

SolrCloud Zookeeper configSet is managed via LWRP - `solrcloud_zkconfigset`. 

SolrCloud Zookeeper configSets management is enabled by default for all nodes.
It means all nodes will get the configSets and will try to manage it against 
one of the configured zookeeper server via attribute `node.solrcloud.config.solrcloud.zkHost`.
 		
    Modify attribute `node.solrcloud.zkconfigsets_manager` to limit zookeeper 
	configSet management to certain nodes in solrcloud cluster.
		

**LWRP example**

*Create a configSet using LWRP:*

    solrcloud_zkconfigset configset_name
      option option_name
    end


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
            "action": "delete",
			"option name": "option value"
          }
        }
	  }
    }

> configSets can either be configured in recipe using LWRP or using node attribute `node.solrcloud.zkconfigsets`. 

> configSets defined using attribute `node.solrcloud.zkconfigsets` does not require LWRP.

**LWRP Options**

SolrCloud Zookeeper cmd Reference: https://cwiki.apache.org/confluence/display/solr/Command+Line+Utilities

Parameters:

- *configset_name (required)*			- solrcloud zookeeper configSet name		
- *action (optional)*					- default :create
- *user (optional)*						- configSet directory user permission, default value `node.solrcloud.user`
- *group (optional)*					- configSet directory group permission, default value `node.solrcloud.group`
- *solr_zkcli (optional)*				- solr in built zkcli.sh for configSet upconfig, default value `node.solrcloud.solrzkcli`
- *zkcli (optional)*					- zookeeper client zkCli.sh, default value `node.solrcloud.zkcli`
- *zkhost (optional)*					- zookeeper server, default value `node.solrcloud.zkHost.first`
- *zkconfigsets_home (optional)*		- configSet directory to sore on solrcloud node, default value `node.solrcloud.zkconfigsets_home`
- *zkconfigsets_cookbook (optional)*	- configSet cookbook name, default value `node.solrcloud.zkconfigsets_cookbook`



**LWRP configSet source cookbook/location**

All configSet content must be stored under `node.solrcloud.zkconfigsets_cookbook `/files/default/config set name`.

> Note: All the config file must resides on location `/files/default/config set name`, not inside conf/ folder 

configSets source cookbook is default set to `solrcloud`, managed by attribute `node.solrcloud.zkconfigsets_cookbook`.


## SolrCloud Collection LWRP
  
**LWRP - solrcloud_collection**

SolrCloud collection is managed via LWRP - `solrcloud_collection`. 


**LWRP example**

*Create a collection using LWRP:*


    solrcloud_collection collection_name
      option option_name
    end


*Delete a collection using LWRP:*


    solrcloud_collection collection_name do
      action :delete
    end


*collection via node attribute:*

    "default_attributes": {
      "solrcloud": {
        "collections": {
          "abc": {
            "action": "delete"
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


> collections can either be configured in recipe using LWRP or using node attribute `node.solrcloud.collections`. 

> collections defined using attribute `node.solrcloud.collections` does not require LWRP.

**LWRP Options**

Collection API Reference: https://cwiki.apache.org/confluence/display/solr/Collections+API


Parameters:

- *collection_config_name* (required)			- solrcloud zookeeper configSet name		
- *action* (optional)							- default :create
- *num_shards* (optional)						- collection API parameter numShards, default value 1
- *shards* (optional)							- collection API parameter shards, default value nil
- *router_field* (optional)						- collection API parameter router.field, default value nil
- *async* (optional)							- collection API parameter async, default value nil
- *router_name* (optional)						- collection API parameter router.name, default value nil
- *router_field* (optional)						- collection API parameter router.field, default value nil
- *host* (optional)								- collection API host, solrcloud node (self), default value `node.ipaddress`
- *port* (optional)								- collection API host port, solrcloud port, default value `node.solrcloud.port`
- *ssl* (optional)								- collection API host ssl, default value false
- *create_node_set* (optional)					- collection API parameter createNodeSet, default value nil
- *replication_factor* (optional)				- collection API parameter replicationFactor, default value 1
- *max_shards_per_node* (optional)				- collection API parameter maxShardsPerNode, default value nil

  
## Cookbook Core Attributes

 * `default[:solrcloud][:user]` (default: solr): solr service user
 * `default[:solrcloud][:group]` (default: solr): solr service group
 * `default[:solrcloud][:user_home]` (default: ): solr service user home
 
 * `default[:solrcloud][:setup_user]` (default: true): manage solr user for solr service using `solrcloud::user` cookbook
 * `default[:solrcloud][:notify_restart]` (default: false): notify solr service on a solrcloud resource change
 
 * `default[:solrcloud][:version]` (default: 4.9.0): solr package version

 * `default[:solrcloud][:install_dir]` (default: /usr/local/solr): jetty home directory - jetty.home
 * `default[:solrcloud][:data_dir]` (default: /opt/solr): solr collection data directory - solr.data.dir 
   
			solrconfig.xml for each configSet needs to set dataDir for this location usage, like:
			<dataDir>${solr.data.dir:}/samplecollection</dataDir>
			
 * `default[:solrcloud][:solr_home]` (default: `node[:solrcloud][:install_dir]/solr`): solr home 
 * `default[:solrcloud][:cores_home]` (default: `node[:solrcloud][:solr_home]/cores`): solr collection/core home
 * `default[:solrcloud][:shared_lib]` (default: `node[:solrcloud][:install_dir]`/lib): solr default lib directory
 * `default[:solrcloud][:config_sets]` (default: `node[:solrcloud][:solr_home]/configsets`): solr cores configSets directory
		
 * `default[:solrcloud][:service_name]` (default: solr): solr service name
 * `default[:solrcloud][:dir_mode]` (default: 0755): solr resource default directory
 
 * `default[:solrcloud][:pid_dir]` (default: /var/run/solr): solr pid directory
 * `default[:solrcloud][:log_dir]` (default: /var/log/solr): solr log directory
 
 * `default[:solrcloud][:template_cookbook]` (default: solrcloud): solr template resources cookbook
 * `default[:solrcloud][:zkconfigsets_cookbook]` (default: solrcloud): zookeeper configSet cookbook
 * `default[:solrcloud][:zkconfigsets_home]` (default: `node[:solrcloud][:install_dir]/zkconfigs`): configs location for zookeeper configSet upconfig 
 
 * `default[:solrcloud][:port]` (default: 8983): solr service port 
 * `default[:solrcloud][:zookeeper][:version]` (default: 3.4.6): zookeeper package setup for zkCli.sh

## Cookbook Ulimit Attributes

 * `default[:solrcloud][:limits][:memlock]` (default: unlimited): solr service user memory limit
 * `default[:solrcloud][:limits][:nofile]` (default: 48000): solr service user file limit
 * `default[:solrcloud][:limits][:nproc]` (default: unlimited): solr service user process limit
 
## Cookbook log4j.properties Config Attributes

 * `default[:solrcloud][:log4j][:MaxFileSize]` (default: 10MB): 
 * `default[:solrcloud][:log4j][:MaxBackupIndex]` (default: 10):
 
## Cookbook solr.xml Config Attributes

solr.xml Reference: https://cwiki.apache.org/confluence/display/solr/Format+of+solr.xml

 * `default[:solrcloud][:config][:adminHandler]` (default: org.apache.solr.handler.admin.CoreAdminHandler):
 * `default[:solrcloud][:config][:adminPath]` (default: /solr/admin):
 * `default[:solrcloud][:config][:coreLoadThreads]` (default: 3):
 * `default[:solrcloud][:config][:coreRootDirectory]` (default: `node[:solrcloud][:cores_home]`):
 * `default[:solrcloud][:config][:sharedLib]` (default: `node[:solrcloud][:shared_lib]`):
 * `default[:solrcloud][:config][:managementPath]` (default: ):
 * `default[:solrcloud][:config][:shareSchema]` (default: false):
 * `default[:solrcloud][:config][:transientCacheSize]` (default: 1000000):
 * `default[:solrcloud][:config][:solrcloud][:hostContext]` (default: solr):
 * `default[:solrcloud][:config][:solrcloud][:distribUpdateConnTimeout]` (default: 1000000):
 * `default[:solrcloud][:config][:solrcloud][:distribUpdateSoTimeout]` (default: 1000000):
 * `default[:solrcloud][:config][:solrcloud][:leaderVoteWait]` (default: 1000000):
 * `default[:solrcloud][:config][:solrcloud][:zkClientTimeout]` (default: 15000):
 * `default[:solrcloud][:config][:solrcloud][:zkHost]` (default: []): zookeeper servers, ',' separated, e.g. ["server:port", "server:port"]
 * `default[:solrcloud][:config][:solrcloud][:genericCoredefaultNames]` (default: true):
 * `default[:solrcloud][:config][:shardHandlerFactory][:socketTimeout]` (default: 0):
 * `default[:solrcloud][:config][:shardHandlerFactory][:connTimeout]` (default: 0):
 * `default[:solrcloud][:config][:logging][:enabled]` (default: true):
 * `default[:solrcloud][:config][:logging][:loggingClass]` (default: ):
 * `default[:solrcloud][:config][:logging][:watcher][:loggingSize]` (default: 1000):
 * `default[:solrcloud][:config][:logging][:watcher][:threshold]` (default: INFO):

 
## Cookbook SolrCloud on HDFS Config Attributes

 * `default[:solrcloud][:hdfs][:enable]` (default: false): to run solrcloud on hdfs, set it to `true`
 * `default[:solrcloud][:hdfs][:directory_factory]` (default: HdfsDirectoryFactory): 
 * `default[:solrcloud][:hdfs][:lock_type]` (default: hdfs): 
 * `default[:solrcloud][:hdfs][:hdfs_home]` (default: nil): syntax: 'hdfs://host:port/path'

> Note: SolrCloud on HDFS is not tested, check online [solr on hdfs] for more info

 
## Cookbook Dependencies

* `ulimit` cookbook
* `java` cookbook

## A Simple Cluster Deployment

To use this cookbook, simply add `recipe[solrcloud::tarball]` to node or role run_list.

*Update common options if required:*

	"default_attributes": {
      "solrcloud": {
        "port": "8080",
        "zkconfigsets_cookbook": "solrcloudconfig",
        "data_dir": "/mnt/solr",
        "setup_user": false,
        "notify_restart": false
      } 
	}

*Update cluster/environment specific options if required:*

    "default_attributes": {
      "solrcloud": {
        "zkconfigsets_manager": true,
        "config": {
          "solrcloud": {
            "zkHost": [
              "10.0.0.1:9983"
            ]
          }
        },
        "collections": {
          "abc": {
            "action": "create",
            "num_shards": "1",
            "name": "abc",
            "replication_factor": "1",
            "collection_config_name": "abc"
          },
          "xyz": {
            "name": "xyz",
            "collection_config_name": "xyz"
          }
        },
        "zkconfigsets": {
          "abc": {
            "action": "create"
          },
          "xyz": {
          }
        }
      }
  	}
  
For testing purpose one of the node can start zookeeper (e.g. 10.0.0.1), to start solr with zookeeper 
on a node, add below parameter to the node:

      "solrcloud": {
	    "zk_run": true
	  }
  
Adjust node with zookeeper ip address, example is using ip address 10.0.0.1.


## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Write description about changes 
7. Submit a Pull Request using Github

## Copyright & License

Authors:: Virender Khatri (vir.khatri@gmail.com)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.



[Jetty]: http://wiki.apache.org/solr/SolrJetty
[Apache Solr]: http://lucene.apache.org/solr/
[solr on hdfs]: https://cwiki.apache.org/confluence/display/solr/Running+Solr+on+HDFS
