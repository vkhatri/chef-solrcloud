#
# Cookbook Name:: solrcloud
# Library:: helpers
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

require 'net/http'
require 'json'

module SolrCloud
  class SolrCollection
    attr_accessor :options, :conn

    def initialize(opts={})
      @options    = opts
      connect
    end

    def connect
      if @options[:ssl]
        @conn = Net::HTTP.new @options[:host], @options[:port]
        @conn.use_ssl = true
        @conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      else
        @conn = Net::HTTP.new @options[:host], @options[:port]
      end
    end

    def collection? collection
      collections.include? collection
    end

    def collections
      reply = conn.request Net::HTTP::Get.new "/solr/admin/collections?wt=json&action=LIST"
      if reply.code.to_i == 200
        return (JSON.parse(reply.body))['collections']
      else
        Chef::Log.error("/solr/admin/collections?wt=json&action=LIST failed")
        return []
      end
    end

    def add_collection
      Chef::Log.info("collection #{@options[:name]} adding ..")
      url = "/solr/admin/collections?wt=json&action=CREATE&name=#{@options[:name]}&replicationFactor=#{@options[:replicationFactor]}"
      url << "&numShards=#{@options[:num_shards]}" if @options[:num_shards]
      url << "&shards=#{@options[:shards]}" if @options[:shards]
      url << "&maxShardsPerNode=#{@options[:max_shards_per_node]}" if @options[:max_shards_per_node]
      url << "&createNodeSet=#{@options[:create_node_set]}" if @options[:create_node_set]
      url << "&collection.configName=#{@options[:collection_config_name]}" if @options[:collection_config_name]
      url << "&router.name=#{@options[:router_name]}" if @options[:router_name]
      url << "&router.field=#{@options[:router_field]}" if @options[:router_field]
      url << "&async=#{@options[:async]}" if @options[:async]
      reply = conn.request Net::HTTP::Post.new url
      if reply.code.to_i == 200
        Chef::Log.info("collection #{@options[:name]} added. => #{JSON.pretty_generate(JSON.parse(reply.body))}")
        return true
      else
        Chef::Log.error("collection #{@options[:name]} failed to add. => #{JSON.pretty_generate(JSON.parse(reply.body))}")
        return false
      end
    end

    def delete_collection
      Chef::Log.info("collection #{@options[:name]} deleting ..")
      url = "/solr/admin/collections?wt=json&action=DELETE&name=#{@options[:name]}"
      reply = conn.request Net::HTTP::Post.new url
      if reply.code.to_i == 200
        Chef::Log.info("collection #{@options[:name]} deleted. => #{JSON.pretty_generate(JSON.parse(reply.body))}")
        return true
      else
        Chef::Log.error("collection #{@options[:name]} failed to delete. => #{JSON.pretty_generate(JSON.parse(reply.body))}")
        return false
      end
    end

  end
end

