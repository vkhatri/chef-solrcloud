#
# Cookbook Name:: solrcloud
# Definition:: solrcloud_configset
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

define  :solrcloud_configset do
#        :action         => 'create' do

  case params[:action]
  when 'remove'
    bash "delete_config_set_#{params[:name]}" do
      user  "root"
      cwd   "/tmp"
      code <<-EOS
      # #{params[:zkcli]} -zkhost #{params[:zkhost]} -cmd downconfig -confdir #{File.join(params[:configsets_home], params[:name], 'conf')} -confname #{params[:name]};
      EOS
      action  :nothing
    end

    directory File.join(params[:configsets_home], params[:name]) do
      action    :delete
    end
  else

    directory File.join(params[:configsets_home], params[:name]) do
      owner       params[:user]
      group       params[:group]
      mode        0644
      recursive   true
      action      :create
    end

    remote_directory File.join(params[:configsets_home], params[:name], 'conf') do
      cookbook    params[:configsets_cookbook]
      source      "/#{params[:configset_name]}"
      #source      "/#{params[:configset_name] || params[:name]}"
      owner       params[:user]
      group       params[:group]
      mode        0644
      files_mode  0644
      files_owner params[:user]
      files_group params[:group]
      action      :create
    end

    bash "create_config_set_#{params[:name]}" do
      user  "root"
      cwd   "/tmp"
      code <<-EOS
      #{params[:zkcli]} -zkhost #{params[:zkhost]} -cmd upconfig -confdir #{File.join(params[:configsets_home], params[:name], 'conf')} -confname #{params[:name]};
      EOS
      action  :nothing
      only_if { File.exists?(File.join(params[:configsets_home], params[:name], 'conf')) }
    end
  end
  
end
