solrcloud Cookbook
==================
This is an OpsCode Chef cookbook for Apache SolrCloud.

It was primarily developed for Testing SolrCloud and its features. 

Currently it supports only In-built Jetty based SolrCloud deployment, more
features and attributes will be added over time, **feel free to contribute** 
what you find missing!

SolrCloud is the default deployment and Solr Master/Slave setup is not supported
by this cookbook and has no plan of adding support for it.


## Supported Solr Runtime 

* In Built Jetty Based SolrCloud deployment


## Supported Solr Package Deployments

* Apache Solr Tarball based deployments


## Support JDK Versions

Check Apache Solr for JDK Version requirement, Oracle JDK 7 is recommended.


## Recipes


## SolrCloud Collection LWRP

## SolrCloud Config Set - Zookeeper LWRP

## Core Attributes

## Advanced Attributes

## Dependencies

* ulimit cookbook
* java cookbook

## Usage


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

