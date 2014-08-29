#
# Cookbook Name:: solrcloud
# Library:: solrcloud
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
  # Solr Collection Management Class. Available Class methods:
  class SolrCollection
    attr_accessor :options, :conn, :headers

    def initialize(opts = {})
      # opts = {
      #   :host [String] => 'solr host',
      #   :port [String] => 'solr host port',
      #   :ssl [Boolean]=> 'use https instead',
      # }
      @options    = opts
      @headers    = {
        'Accept' => 'application/json',
        'Keep-Alive' => '120',
        'Content-Type' => 'application/json'
      }
      connect
    end

    def connect
      # Check Port Connectivity and Set  HTTP connection
      begin
        if options[:ssl]
          TCPSocket.new(options[:host], options[:ssl_port])
          Chef::Log.info("connecting to solr host=#{options[:host]} on ssl port=#{options[:ssl_port]}")
          @conn = Net::HTTP.new options[:host], options[:ssl_port]
          @conn.use_ssl = true
          @conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
        else
          TCPSocket.new(options[:host], options[:port])
          Chef::Log.info("connecting to solr host=#{options[:host]} on port=#{options[:port]}")
          @conn = Net::HTTP.new options[:host], options[:port]
        end
      rescue => error
        raise "solr service port is down or inaccessible #{options[:ssl] ? options[:ssl_port] : options[:port]}, #{error.class} - #{error.message}"
      end
    end

    def collection?(collection)
      collections.include? collection
    end

    def collections
      reply = conn.request Net::HTTP::Get.new "/solr/admin/collections?wt=json&action=LIST", headers
      if reply.code.to_i == 200
        return (JSON.parse(reply.body))['collections']
      else
        raise "/solr/admin/collections?wt=json&action=LIST api call failed. => #{JSON.pretty_generate(JSON.parse(reply.body))}"
      end
    end

    def create_collection
      Chef::Log.info("collection #{options[:name]} creating ..")
      url = "/solr/admin/collections?wt=json&action=CREATE&name=#{options[:name]}&replicationFactor=#{options[:replication_factor]}"
      url << "&numShards=#{options[:num_shards]}" if options[:num_shards]
      url << "&shards=#{options[:shards]}" if options[:shards]
      url << "&maxShardsPerNode=#{options[:max_shards_per_node]}" if options[:max_shards_per_node]
      url << "&createNodeSet=#{options[:create_node_set]}" if options[:create_node_set]
      url << "&collection.configName=#{options[:collection_config_name]}" if options[:collection_config_name]
      url << "&router.name=#{options[:router_name]}" if options[:router_name]
      url << "&router.field=#{options[:router_field]}" if options[:router_field]
      url << "&async=#{options[:async]}" if options[:async]
      reply = conn.request Net::HTTP::Post.new url, headers
      data  = JSON.pretty_generate(JSON.parse(reply.body))

      if reply.code.to_i == 200
        Chef::Log.info("collection #{options[:name]} created. => #{data}")
        return true
      else
        raise "#{url}, collection #{options[:name]} failed to create. => #{data}"
        return false
      end
    end

    def delete_collection
      Chef::Log.info("collection #{options[:name]} deleting ..")
      url = "/solr/admin/collections?wt=json&action=DELETE&name=#{options[:name]}"
      reply = conn.request Net::HTTP::Post.new url, headers
      data = JSON.pretty_generate(JSON.parse(reply.body))
      if reply.code.to_i == 200
        Chef::Log.info("collection #{options[:name]} deleted. => #{data}")
        return true
      else
        raise "#{url}, collection #{options[:name]} failed to delete. => #{data}"
        return false
      end
    end

  end
end

