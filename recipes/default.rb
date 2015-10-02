#
# Cookbook Name:: solrcloud
# Recipe:: default
#
# Copyright 2014, Virender Khatri
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# set default derived attributes
include_recipe 'solrcloud::attributes'

# install solr from tarball
include_recipe 'solrcloud::tarball'

# setup zookeeper client
include_recipe 'solrcloud::zkcli'

# configure solr
include_recipe 'solrcloud::config'

# configure jetty
include_recipe 'solrcloud::jetty'

# solr service
include_recipe 'solrcloud::service'

# setup configsets - node['solrcloud']['zkconfigsets']
include_recipe 'solrcloud::zkconfigsets'

# setup collections - node['solrcloud']['collections']
include_recipe 'solrcloud::collections'
