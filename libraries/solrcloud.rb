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
    attr_accessor :conn, :headers

    def initialize(opts = {})
      # opts = {
      #   :host [String] => 'solr host',
      #   :port [String] => 'solr host port',
      #   :ssl_port [String] => 'solr host port',
      #   :use_ssl [Boolean]=> 'use https instead',
      # }
      @options    = opts
      @headers    = {
        'Accept' => 'application/json',
        'Keep-Alive' => '120',
        'Content-Type' => 'application/json'
      }
      connect(opts[:host], opts[:port], opts[:ssl_port], opts[:use_ssl])
    end

    def connect(host, port, ssl_port, use_ssl = false)
      host_port = use_ssl ? ssl_port : port
      begin
        TCPSocket.new(host, host_port)
      rescue => error
        raise "solr service port is down or inaccessible #{host_port}, #{error.class} - #{error.message}"
      end
      Chef::Log.info("connecting to solr host=#{host} on ssl port=#{host_port}")
      @conn = Net::HTTP.new host, host_port
      if use_ssl
        @conn.use_ssl = true
        @conn.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
    end

    def collection?(name)
      collections.include? name
    end

    def collections
      reply = conn.request(Net::HTTP::Get.new("/solr/admin/collections?wt=json&action=LIST", headers))
      if reply.code.to_i == 200
        return (JSON.parse(reply.body))['collections']
      else
        raise "/solr/admin/collections?wt=json&action=LIST api call failed. => #{JSON.pretty_generate(JSON.parse(reply.body))}"
      end
    end

    def create_collection(opts)
      Chef::Log.info("collection #{opts[:name]} creating ..")
      # Required Parameters
      url = "/solr/admin/collections?wt=json&action=CREATE&name=#{opts[:name]}&replicationFactor=#{opts[:replication_factor]}"
      # Optional Parameters
      url << "&numShards=#{opts[:num_shards]}" if opts[:num_shards]
      url << "&shards=#{opts[:shards]}" if opts[:shards]
      url << "&maxShardsPerNode=#{opts[:max_shards_per_node]}" if opts[:max_shards_per_node]
      url << "&createNodeSet=#{opts[:create_node_set]}" if opts[:create_node_set]
      url << "&collection.configName=#{opts[:collection_config_name]}" if opts[:collection_config_name]
      url << "&router.name=#{opts[:router_name]}" if opts[:router_name]
      url << "&router.field=#{otps[:router_field]}" if opts[:router_field]
      url << "&async=#{opts[:async]}" if opts[:async]
      reply = conn.request Net::HTTP::Post.new url, headers
      data  = JSON.pretty_generate(JSON.parse(reply.body))

      if reply.code.to_i == 200
        Chef::Log.info("collection #{opts[:name]} created. => #{data}")
        return true
      else
        raise "#{url}, collection #{opts[:name]} failed to create. => #{data}"
        return false
      end
    end

    def delete_collection(name)
      Chef::Log.info("collection #{name} deleting ..")
      url = "/solr/admin/collections?wt=json&action=DELETE&name=#{name}"
      reply = conn.request Net::HTTP::Post.new url, headers
      data = JSON.pretty_generate(JSON.parse(reply.body))
      if reply.code.to_i == 200
        Chef::Log.info("collection #{name} deleted. => #{data}")
        return true
      else
        raise "#{url}, collection #{name} failed to delete. => #{data}"
        return false
      end
    end

  end
end

