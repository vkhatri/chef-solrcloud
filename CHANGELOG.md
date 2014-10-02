solrcloud CHANGELOG
===================

This file is used to list changes made in each version of the solrcloud cookbook.

0.3.9
-----

- vkhatri - Fixed solr key store file generation, issue #11

0.3.8
-----

- vkhatri - fixed cookbook for foodcritic test passed ok

- vkhatri - added all zkconfig lwrp options to recipe

- vkhatri - added gcc dep for zk gem, issue #8

- vkhatri - fixed zkconfigset lwrp to upload missing zk configs, issue #7

- timoschmidt - removed Gem.clear_path, fix for OpsWorks runtime error, issue #5

0.3.4
-----

- vkhatri - fixed zk gem install patch package dependency error

0.3.3
-----

- vkhatri - added java dependency

0.3.2
-----

- vkhatri - bumped solr version to 4.10.0

- vkhatri - removed attribute adminPath for v4.10.0, caused startup failure

- vkhatri - updated README.md

- vkhatri - fix for foodcrtic

0.3.0
-----
- vkhatri - made lwrp a bit better using ruby gem zk, fix #1

- vkhatri - added another attribute for zookeeper configSet upload

- vkhatri - changed failure to raise an Exception instead of Chef::Application.fatal!

- vkhatri - java Options attribute is now an Array

- vkhatri - added Auto Java Memory attribute file

- vkhatri - disabled default Node zkConfigSets and collections manage attribute

- vkhatri - added zkConfigSets source management attribute - zkconfigsets_source

- vkhatri - disabled CONSOLE logging in log4j.properties and added more template attributes

0.2.8
-----
- vkhatri - Added node java_options attribute

- vkhatri - Fixed Collection LWRP for stopped solr service and in why run mode

- Updated README content with correct attributes

- Updated collection LWRP to work with solr ssl, for future cases where only ssl service port is available.

0.2.6
-----
- vkhatri - Fixed Typo Changes in README examples


0.2.5
-----
- vkhatri - Renamed solr.xml node attributes convention to generic

- vkhatri - Added Request Log attributes

- vkhatri - Added Jetty JMX

- vkhatri - Added JMX Authentication & Authorization

- vkhatri - Added Jetty SSL

- vkhatri - Added Solr Service Startup Wait Time attribute

- vkhatri - Updated configSet now will notify zookeeper upconfig

- vkhatri - Added Jetty Server Core attributes

- vkhatri - Added Jetty default connector attributes

- vkhatri - Added Jetty SSL connector attributes

- vkhatri - Added SSL key store file

- vkhatri - Added Default key store file generation and management

- vkhatri - Added User defined key store file SSL

- vkhatri - Separated manager attribute to  collection manager, zkconfigSet managet and zkconfigSet source manager

- vkhatri - Fixed collection first time run failure due to solr service down, now logs a message when solr service is down

- vkhatri - Updated collection LWRP, now if manage_collections is disabled, LWRP would not create collection resource

- vkhatri - Updated zkconfigsets LWRP, now if manage_zkconfigsets is disabled, LWRP would not create zkconfigsets zookeeper upconfig resource

- vkhatri - Updated zkconfigsets LWRP, now if manage_zkconfigsets_source is disabled, LWRP would not create zkconfigsets source resource

0.2.1
-----
- vkhatri - Updated README and CHANGELOG

0.2.0
-----
- vkhatri - Initial release of solrcloud

- - -
[Github Source](https://github.com/vkhatri/solrcloud)

Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
