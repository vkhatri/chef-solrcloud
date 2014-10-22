solrcloud CHANGELOG
===================

This file is used to list changes made in each version of the solrcloud cookbook.

New
-----

- Timo Schmidt - Added collection API parameter 'autoAddReplicas'

- Virender Khatri - Rubocop ready

0.4.3
-----

- Virender Khatri - bump apache solr version to 4.10.1 after a basic test run


0.4.2
-----

- Timo Schmidt - added attribute force_upload to zkconfigset lwrp to always upload
  zkconfigsets to zookeeper, useful when manage configset separately

- Timo Schmidt - create directory for JETTY_RUN if missing for debian platform family

- Virender Khatri - added attribute for jetty context configuration


0.3.9
-----

- Virender Khatri - Fixed solr key store file generation, issue #11

0.3.8
-----

- Virender Khatri - fixed cookbook for foodcritic test passed ok

- Virender Khatri - added all zkconfig lwrp options to recipe

- Virender Khatri - added gcc dep for zk gem, issue #8

- Virender Khatri - fixed zkconfigset lwrp to upload missing zk configs, issue #7

- Timo Schmidt - removed Gem.clear_path, fix for OpsWorks runtime error, issue #5

0.3.4
-----

- Virender Khatri - fixed zk gem install patch package dependency error

0.3.3
-----

- Virender Khatri - added java dependency

0.3.2
-----

- Virender Khatri - bumped solr version to 4.10.0

- Virender Khatri - removed attribute adminPath for v4.10.0, caused startup failure

- Virender Khatri - updated README.md

- Virender Khatri - fix for foodcrtic

0.3.0
-----
- Virender Khatri - made lwrp a bit better using ruby gem zk, fix #1

- Virender Khatri - added another attribute for zookeeper configSet upload

- Virender Khatri - changed failure to raise an Exception instead of Chef::Application.fatal!

- Virender Khatri - java Options attribute is now an Array

- Virender Khatri - added Auto Java Memory attribute file

- Virender Khatri - disabled default Node zkConfigSets and collections manage attribute

- Virender Khatri - added zkConfigSets source management attribute - zkconfigsets_source

- Virender Khatri - disabled CONSOLE logging in log4j.properties and added more template attributes

0.2.8
-----
- Virender Khatri - Added node java_options attribute

- Virender Khatri - Fixed Collection LWRP for stopped solr service and in why run mode

- Updated README content with correct attributes

- Updated collection LWRP to work with solr ssl, for future cases where only ssl service port is available.

0.2.6
-----
- Virender Khatri - Fixed Typo Changes in README examples


0.2.5
-----
- Virender Khatri - Renamed solr.xml node attributes convention to generic

- Virender Khatri - Added Request Log attributes

- Virender Khatri - Added Jetty JMX

- Virender Khatri - Added JMX Authentication & Authorization

- Virender Khatri - Added Jetty SSL

- Virender Khatri - Added Solr Service Startup Wait Time attribute

- Virender Khatri - Updated configSet now will notify zookeeper upconfig

- Virender Khatri - Added Jetty Server Core attributes

- Virender Khatri - Added Jetty default connector attributes

- Virender Khatri - Added Jetty SSL connector attributes

- Virender Khatri - Added SSL key store file

- Virender Khatri - Added Default key store file generation and management

- Virender Khatri - Added User defined key store file SSL

- Virender Khatri - Separated manager attribute to  collection manager, zkconfigSet managet and zkconfigSet source manager

- Virender Khatri - Fixed collection first time run failure due to solr service down, now logs a message when solr service is down

- Virender Khatri - Updated collection LWRP, now if manage_collections is disabled, LWRP would not create collection resource

- Virender Khatri - Updated zkconfigsets LWRP, now if manage_zkconfigsets is disabled, LWRP would not create zkconfigsets zookeeper upconfig resource

- Virender Khatri - Updated zkconfigsets LWRP, now if manage_zkconfigsets_source is disabled, LWRP would not create zkconfigsets source resource

0.2.1
-----
- Virender Khatri - Updated README and CHANGELOG

0.2.0
-----
- Virender Khatri - Initial release of solrcloud

- - -
[Github Source](https://github.com/Virender Khatri/solrcloud)

Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
