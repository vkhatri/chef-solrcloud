#
# Cookbook Name:: solrcloud
# Recipe:: user
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

require 'spec_helper'

describe 'solrcloud::user' do
  let(:chef_run) { ChefSpec::Runner.new(:platform => 'ubuntu', :version => '12.04').converge(described_recipe) }

  it 'adds group solr' do
    expect(chef_run).to create_group('solr')
  end

  it 'adds user solr' do
    expect(chef_run).to create_user('solr')
  end
end
