require 'spec_helper'

describe 'solrcloud::default' do
  shared_examples_for 'solr' do
    context 'all_platforms' do
      # tarball
      %w(attributes tarball user java zkcli config jetty service zkconfigsets collections).each do |r|
        it "include recipe solrcloud::#{r}" do
          expect(chef_run).to include_recipe("solrcloud::#{r}")
        end
      end

      it 'install chec_gem zk' do
        expect(chef_run).to install_chef_gem('zk').at_compile_time
      end

      %w(patch gcc make).each do |p|
        it "install package #{p}" do
          expect(chef_run).to install_package(p).at_compile_time
        end
      end

      it 'download solr tarball file' do
        expect(chef_run).to create_remote_file('solr_tarball_file')
      end

      it 'run extract solr tarball file' do
        expect(chef_run).to run_bash('extract_solr_tarball')
      end

      it 'link install_dir to source_dir' do
        expect(chef_run).to create_link('/usr/local/solr')
      end

      %w(/opt/solr /var/log/solr /var/run/solr /usr/local/solr/solr /usr/local/solr/solr/configsets /usr/local/solr/solr/cores/ /usr/local/solr_zkconfigsets /usr/local/solr/etc /usr/local/solr/resources /usr/local/solr/webapps /usr/local/solr/contexts /usr/local/solr/zookeeperdata).each do |d|
        it "create directory #{d}" do
          expect(chef_run).to create_directory(d)
        end
      end

      it 'run ruby_block require_pam_limits.so' do
        expect(chef_run).to run_ruby_block('require_pam_limits.so')
      end

      it 'create link /usr/local/solr/lib' do
        expect(chef_run).to create_link('/usr/local/solr/lib')
      end

      it 'create link /usr/local/solr/start.jar' do
        expect(chef_run).to create_link('/usr/local/solr/start.jar')
      end

      it 'create link /usr/local/solr/webapps/solr.war' do
        expect(chef_run).to create_link('/usr/local/solr/webapps/solr.war')
      end

      it 'run ruby_block purge_old_versions' do
        expect(chef_run).to run_ruby_block('purge_old_versions')
      end
      it 'delete remote_file solr_tarball_file' do
        expect(chef_run).to delete_remote_file('local_solr_tarball_file')
      end

      # user
      it 'add group solr' do
        expect(chef_run).to create_group('solr')
      end

      it 'add user solr' do
        expect(chef_run).to create_user('solr')
      end

      # zkcli
      it 'download zookeeper tarball file' do
        expect(chef_run).to create_remote_file('zookeeper_tarball_file')
      end

      it 'run extract zookeeper tarball file' do
        expect(chef_run).to run_bash('extract_zookeeper_tarball')
      end

      # config
      it 'create template /usr/local/solr/solr/solr.xml' do
        expect(chef_run).to create_template('/usr/local/solr/solr/solr.xml').with(
          source: 'solr.xml.erb'
        )
      end

      it 'create template /usr/local/solr/solr/zoo.cfg' do
        expect(chef_run).to create_template('/usr/local/solr/solr/zoo.cfg').with(
          source: 'zoo.cfg.erb'
        )
      end

      it 'create template /usr/local/solr/zookeeper/conf/zoo.cfg' do
        expect(chef_run).to create_template('/usr/local/solr/zookeeper/conf/zoo.cfg').with(
          source: 'zoo.cfg.erb'
        )
      end

      it 'create template /usr/local/solr/zookeeper/bin/zkEnv.sh' do
        expect(chef_run).to create_template('/usr/local/solr/zookeeper/bin/zkEnv.sh').with(
          source: 'zkEnv.sh.erb'
        )
      end

      it 'create template /usr/local/solr/resources/log4j.properties' do
        expect(chef_run).to create_template('/usr/local/solr/resources/log4j.properties').with(
          source: 'log4j.properties.erb'
        )
      end

      it 'create template /usr/local/solr/contexts/solr-jetty-context.xml' do
        expect(chef_run).to create_template('/usr/local/solr/contexts/solr-jetty-context.xml').with(
          source: 'solr-jetty-context.xml.erb'
        )
      end

      it 'create template /usr/local/solr/etc/webdefault.xml' do
        expect(chef_run).to create_template('/usr/local/solr/etc/webdefault.xml').with(
          source: 'webdefault.xml.erb'
        )
      end

      it 'create template /usr/local/solr/etc/jetty.xml' do
        expect(chef_run).to create_template('/usr/local/solr/etc/jetty.xml').with(
          source: 'jetty.xml.erb'
        )
      end

      it 'create template /usr/local/solr/etc/create-solr.keystore.sh' do
        expect(chef_run).to create_template('/usr/local/solr/etc/create-solr.keystore.sh').with(
          source: 'create-solr.keystore.sh.erb'
        )
      end

      it 'create template /usr/local/solr/resources/jmxremote.access' do
        expect(chef_run).to create_template('/usr/local/solr/resources/jmxremote.access').with(
          source: 'jmxremote.access.erb'
        )
      end

      it 'create template /usr/local/solr/resources/jmxremote.password' do
        expect(chef_run).to create_template('/usr/local/solr/resources/jmxremote.password').with(
          source: 'jmxremote.password.erb'
        )
      end

      # service
      it 'create template solr environment config file' do
        expect(chef_run).to create_template('solr_config')
      end

      it 'create template /etc/init.d/solr' do
        expect(chef_run).to create_template('/etc/init.d/solr')
      end

      it 'enable solr service' do
        expect(chef_run).to enable_service('solr')
        expect(chef_run).to start_service('solr')
      end
    end
  end

  context 'ubuntu' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(:platform => 'ubuntu', :version => '12.04') do |node|
        node.set['solrcloud']['zk_run'] = true
        node.set['solrcloud']['tarball_purge'] = true
      end.converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('zk').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('net/http').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('json').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('tmpdir').and_return(true)
    end

    include_examples 'solr'
  end

  context 'centos' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new(:platform => 'centos', :version => '6.5') do |node|
        node.set['solrcloud']['zk_run'] = true
        node.set['solrcloud']['tarball_purge'] = true
      end.converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('zk').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('net/http').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('json').and_return(true)
      allow_any_instance_of(Chef::Recipe).to receive(:require).with('tmpdir').and_return(true)
    end

    include_examples 'solr'
  end
end
