#
# Cookbook Name:: solrcloud
# Library:: helper
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

module SolrCloud

  require 'net/http'
  require 'json'

  def self.setup_collection(opts={})
    if opts[:run]
    opts[:ssl]  ||= false

    if opts[:ssl]
      conn = Net::HTTP.new opts[:host], opts[:port]
      conn.use_ssl = true
      conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
    else
      conn = Net::HTTP.new opts[:host], opts[:port]
    end

    collection_reply = conn.request Net::HTTP::Get.new "/solr/admin/collections?wt=json&action=LIST"
    
    if collection_reply.code.to_i != 200
      Chef::Log.error("/solr/admin/collections?wt=json&action=LIST failed")
      collections = []
    else
      collections = (JSON.parse(collection_reply.body))['collections']

      case opts[:action]
      when 'delete'
        if collections.include? opts[:name]
          Chef::Log.info("collection #{opts[:name]} deleting ..")
          url = "/solr/admin/collections?wt=json&action=DELETE&name=#{opts[:name]}"
          reply = conn.request Net::HTTP::Post.new url
          if reply.code.to_i == 200
            Chef::Log.info(JSON.pretty_generate(JSON.parse(reply.body)))
            Chef::Log.info("collection #{opts[:name]} deleted.")
          else
            Chef::Log.error(JSON.pretty_generate(JSON.parse(reply.body)))
            Chef::Log.error("collection #{opts[:name]} failed to delete.")
          end
        else
          Chef::Log.info("collection #{opts[:name]} does not exists")
        end
      when 'create'
        if collections.include? opts[:name]
          Chef::Log.info("collection #{opts[:name]} already exists")
        else
          Chef::Log.info("collection #{opts[:name]} adding ..")
          url = "/solr/admin/collections?wt=json&action=CREATE&name=#{opts[:name]}&replicationFactor=#{opts[:replicationFactor]}"
          url << "&numShards=#{opts[:num_shards]}" if opts[:num_shards]
          url << "&shards=#{opts[:shards]}" if opts[:shards]
          url << "&maxShardsPerNode=#{opts[:max_shards_per_node]}" if opts[:max_shards_per_node]
          url << "&createNodeSet=#{opts[:create_node_set]}" if opts[:create_node_set]
          url << "&collection.configName=#{opts[:collection_config_name]}" if opts[:collection_config_name]
          url << "&router.name=#{opts[:router_name]}" if opts[:router_name]
          url << "&router.field=#{opts[:router_field]}" if opts[:router_field]
          url << "&async=#{opts[:async]}" if opts[:async]
          reply = conn.request Net::HTTP::Post.new url
          if reply.code.to_i == 200
            Chef::Log.info(JSON.pretty_generate(JSON.parse(reply.body)))
            Chef::Log.info("collection #{opts[:name]} added.")
          else
            Chef::Log.error(JSON.pretty_generate(JSON.parse(reply.body)))
            Chef::Log.error("collection #{opts[:name]} failed to add.")
          end
        end
      else
        Chef::Log.error("incorrect action, valid are :create, :delete")
      end
    end
    end
  end

end

class Chef::Recipe
  include SolrCloud
end

#class Chef::Resource
#  include SolrCloud
#end

#Chef::Recipe.send(:include, SolrCloud)
